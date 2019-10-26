clear;

buffer_data=fopen('test.bin','r'); %open data buffer (binary file) from solver in READ mode 


planet_b = reshape(fread(buffer_data,'*double'),30,[])'; %read planet values out of file to array resized array
fclose(buffer_data);

%just used to allow single code block to work for two purposes. Allow the
%suns positon to be updated alongside the positon of the orbiting planets.
planet_a =  planet_b;

[columns,count] = size(planet_a); %set data range
 figure(1)
  clf
 i = 1:1:columns/3;
 
%colour bodies, use hold on to draw multiple orbits in the same space
hold on
colours=lines(columns);
title('Oribits of Bodies (des. Planets Scaled)')


j=0; %plot all orbits
for inc = 3:3:(count)
    j=j+1;
 plot3 (planet_a(i,(inc-2)),planet_a(i,(inc-1)), planet_a(i,inc),'-','color',colours(j,:))
end

%explicitly defined order of the planets simulation starting from the sun
set(gca,'color','black')
legend('Sun','Mercuary','Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune' ,'Moon');
set(legend,'color','white');
