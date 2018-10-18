close all;
fprintf('start...\n');
fprintf('connecting to mongoDB...\n');
javaaddpath('C:\Users\Axel\Documents\MATLAB\JAR\mongo-java-driver-3.8.2.jar')
import com.mongodb.*;

mongoClient = MongoClient();
db = mongoClient.getDB( 'main' );
fprintf('find collections...\n');
colls = db.getCollectionNames().toArray();
disp(colls);

currColl = "_70091100056-4/1/13";
disp("currColl="+currColl);

coll = db.getCollection(currColl).findOne().toString().toCharArray;
fprintf('coll=\n');
disp(size(coll))

data = reshape(coll,[1,size(coll)]);

fprintf('json decode...\n');
json = jsondecode(data);
fprintf('json=\n');
disp(json);

fprintf('json ok\n');
fprintf('start parsing...\n');

A = 1;

if A == 2
    fprintf('v2 sensor plot...\n');
    acceleration(json)
end

if A == 1
    fprintf('v1 sensor plot...\n');
    animalArray = json.animals;
    rows = size(animalArray);
    r = rows(1);
    maxCols = 0;
    names = [];
        
        names = strings(1,r);
        figure(); hold on
        for i = 1:size(animalArray)
            times = [];
            values = [];
            tagDataArray = animalArray(i).tagData;
            names(i) = tagDataArray(1).serial_number.x_numberLong;
              for j = 1:size(tagDataArray)
                    tag = tagDataArray(j);
                    TF = contains(tag.time,'PM')
                    if TF == 1
                        time = datenum(tag.time, 'HH:MM:SS PM');
                        fprintf("PM\n"+time);
                    end
                    if TF == 0
                        time = datenum(tag.time, 'HH:MM:SS AM');
                        fprintf("AM\n"+time)
                    end
                    value = tag.first_sensor_value;
                    if value < 0
                        value = 0;
                    end
                    values = [values, value];
                    times = [times, time];
                    
                    if j > maxCols
                        maxCols = j;
                    end
              end
              
              
        %values = values(:,1:maxCols);
        
        N = size(animalArray);
        W = floor(sqrt(N));
        width = W(1)+1;
        height = ceil(N/W);
        
        %y = values(i,1:maxCols);
        plot(times, values);  
        datetick('x','HH:MM') 
              
        end
        hold off

        
              %figure(); hold on
              %for m = 1:size(values,1)
                  %subplot(width,height,i);
                  %plot(times(m,:), values(m,:));              % plot the data,
                  %datetick('x','HH:MM')   % give the a xaxis time label ticks..
                  %title(names(m));
              %end
              %hold off
              
end

function acceleration(input)
    animalArray = input.animals;
    xmin = 0;
    ymin = 0;
    zmin = 0;
    xmax = 0;
    ymax = 0;
    zmax = 0;
    gravity = [0, 0, 0];
    linear_acceleration = [0, 0, 0];

    for i = 1:size(animalArray)
       tagDataArray = animalArray(i).tagData;
       x = [];
       y = [];
       z = [];
       time = [];
       name = "unknown";
       for j = 1:size(tagDataArray)
            tag = tagDataArray(j);
            raw = tag.second_sensor_values_xyz;
            name = tag.serial_number.x_numberLong;
            split = strsplit(raw,':');
            xmin = str2double(split(1));ymin = str2double(split(3));
            zmin = str2double(split(5));xmax = str2double(split(2));
            ymax = str2double(split(4));
            zmax = str2double(split(6));
            aplha = 0.8;
            gravity(1) = aplha * gravity(1) + (1 - aplha)*xmin;
            gravity(2) = alpha * gravity(2) + (1 - aplha)*ymin;
            gravity(3) = alpha * gravity(3) + (1 - aplha)*zmin;

            linear_acceleration(1) = xmin - gravity(1);
            linear_acceleration(2) = ymin - gravity(2);
            linear_acceleration(3) = zmin - gravity(3);

            x = [x, linear_acceleration(1)];
            y = [y, linear_acceleration(2)];
            z = [z, linear_acceleration(3)];
            time = [time, j];
       end
       disp(name);
       N = size(animalArray);
       W = floor(sqrt(N));
       width = W(1)+1;
       height = ceil(N/W);

       disp(i);
       subplot(width,height,i);
       plot(time,x,time,y,time,z);
       title(name); 
    end  
end
%scatter3(xmax,ymax,zmax,'filled')