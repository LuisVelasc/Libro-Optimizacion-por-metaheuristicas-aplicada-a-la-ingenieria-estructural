% Se crea el archivo con los datos del nuevo modelo
file = 'VariablesDecision.tcl';

% Se modifica el archivo de las variables de decisión para OpenSees
fileID = fopen(file,'w');
fprintf(fileID, '# Variables de decisión de nuestro modelo. Arcilla media\n');

fprintf(fileID, '# Lista de profundidades de capas de suelo, en m\n')
fprintf(fileID, 'set H {%2.1f %2.1f %2.1f %2.1f %2.1f %2.1f %2.1f};\n\n', md(1,:));

fprintf(fileID, '# Densidad del terreno en kg/m3\n')
fprintf(fileID, 'set rho {%d %d %d %d %d %d %d};\n\n', md(2,:));

fprintf(fileID, '# Módulo a cortante en kPa\n')
fprintf(fileID, 'set Gr {%d %d %d %d %d %d %d};\n\n', md(3,:));

fprintf(fileID, '# Módulo de Bulk en kPa\n')
fprintf(fileID, 'set Br {%d %d %d %d %d %d %d};\n\n', md(4,:));

fprintf(fileID, '# Cohesión del terreno en kPa\n')
fprintf(fileID, 'set c {%2.1f %2.1f %2.1f %2.1f %2.1f %2.1f %2.1f};\n\n', md(5,:));

fprintf(fileID, '# Presión de referencia en kPa\n')
fprintf(fileID, 'set refPress {%2.1f %2.1f %2.1f %2.1f %2.1f %2.1f %2.1f};\n\n', md(6,:));

type(file);
fclose(fileID);