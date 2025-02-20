# Se modela la respuesta dinámica de una columna de suelo blando, los valores utilizados
# son de referencia y se toman del manual en línea de OpenSees. Link:
# https://opensees.berkeley.edu/wiki/index.php/PressureIndependMultiYield_Material 

# Se crea un modelo de 2 dimensiones y dos grados de libertar por nodo
wipe
model BasicBuilder -ndm 2 -ndf 2
set pi 3.141592654;

# Se definen los parámetros del modelo
set N 7;		# Número de capas de suelo
set gammaPeak 0.1;	# Deformación a cortante máxima
set phi 0.0; 		# Ángulo de fricción
set presCoef 0.0; 	# Coeficiente de presión de referencia
set nu 0.0; 		# Módulo de Poisson
set B 3.0;		# Ancho columna considerada en m
set Esp 1.0;		# Espesor elementos en m

# Variables de decisión de las capas de suelo
source VariablesDecision.tcl

# Valores del terreno subyacente
set rockVs 800;    # Velocidad de ondas en m/s
set rockDen 2.4e3; # Densidad del lecho rocoso en kg/m3

# Se define los nodos del modelo
set Hd [lindex $H [expr $N-1]]
for {set j 1} {$j <= [expr (2*$N)+1]} {incr j 2} {
	if {$j==1} {
		node $j          0.0 0.0
    		node [expr $j+1] $B  0.0
	} elseif {$j==[expr (2*$N)+1]} { 
		node $j          0.0 $Hd
    		node [expr $j+1] $B  $Hd
	} else {
    		node $j          0.0 [expr $Hd-[lindex $H [expr ($N-2)-($j-3)/2]]]
    		node [expr $j+1] $B  [expr $Hd-[lindex $H [expr ($N-2)-($j-3)/2]]]
	}; # Fin if
}; # Fin for

# Se definen apoyos fijos en la base de la columna de suelo
fix 1 0 1
fix 2 0 1

# Se ligan los GDL traslasionales de la columna de suelo
for {set k 3} {$k <= [expr (2*$N)+1]} {incr k 2} {
    equalDOF  $k  [expr $k+1]  1 2
}

# Definir nodos para el amortiguamiento, elemento de longiud zero
node 100 0.0 0.0
node 101 0.0 0.0

# Definir los apoyos como fijos del amortiguamiento
fix 100 1 1
fix 101 0 1

# Se ligan los desplaamientos laterales de los nodos
equalDOF 1   2 1
equalDOF 1 101 1

# Se definen los materiales de los elementos
for {set j 0} {$j <= [expr $N-1]} {incr j 1} {
     set k [expr $N-1-$j]
     nDMaterial PressureIndependMultiYield 10$j 2 [lindex $rho $k] [lindex $Gr $k] [lindex $Br $k] [lindex $c $k] $gammaPeak $phi [lindex $refPress $k] $presCoef
}

# Material uniaxial viscoso
set C [expr $B*$rockVs*$rockDen]
uniaxialMaterial Viscous 201 $C 1

# Se definen los elementos del modelo
for {set j 0} {$j <= [expr $N-1]} {incr j 1} {
     set k [expr $N-1-$j]     
     set Wx 0.0;
     set Wy [expr [lindex $rho $k]*-9.81/1000]; 
     element quad 30$j [expr 2*$j+1] [expr 2*$j+2] [expr 2*$j+4] [expr 2*$j+3] $Esp "PlaneStrain" 10$j 0.0 [lindex $rho $k] $Wx $Wy
}

# Elemento de longitud zero para el amortiguamiento
element zeroLength 401 100 101 -mat 201 -dir 1

# Se define la ventana que permitirá visualizar el modelo.
#    recorder display "Columna suelo" 10 10 600 600 -wipe
 #   prp 0 0 50
  #  vup 0 1 0
   # vpn 0 0 1
    #display 1 2 10  

# Se realiza el análisis estático
system BandGeneral
numberer RCM
constraints Plain
test NormDispIncr 1.0e-2 25;
integrator LoadControl 0.1
algorithm Newton
analysis Static
analyze 10

# Se definen los registros a guardar
recorder Node -file DespTop.out -node 15 -dof 1 disp;

# Se realiza análisis dinámico
setTime 0.0
wipeAnalysis

set Factor 0.01; # El registro de aceleraciones se encuentra en cm/s2, este factor lo convierte a m/s2.
set dt 0.01; # Diferencial de tiempo del acelerograma.
set Npuntos 18000; # Número de puntos del acelerograma.
set AccelDataFile "SCT18509.txt"; # Se indica el registro a utilizar.
set DirX 1; # Dirección en la que se aplicarán las aceleraciones.

# Se define el patrón de aceleraciones.
set accelSeries "Series -dt $dt -filePath $AccelDataFile -factor $Factor";
pattern UniformExcitation 2 $DirX -accel $accelSeries

# Se define el amortiguamiento de la estructura.
set dampRatio 0.02
set omega1 [expr 2*$pi*0.2];	# lower frequency
set omega2 [expr 2*$pi*20];	# upper frequency
set a0 [expr 2*$dampRatio*$omega1*$omega2/($omega1 + $omega2)]; # coeficientes de amortiguamiento
set a1 [expr 2*$dampRatio/($omega1 + $omega2)];
rayleigh $a0 $a1 0.0 0.0

# Se definen los parámetros del análisis estático.
system UmfPack
numberer RCM
constraints Plain
test NormDispIncr 1.0e-8 10
integrator Newmark 0.5 0.25
algorithm Newton
analysis Transient
analyze $Npuntos $dt


