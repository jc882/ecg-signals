fid=fopen('train500.txt');
%file that contains the names of data files for i=1:number_of_files
highPass_filtered=[];
features_extracted=[];
for i=1:477
file=fgetl(fid);
load(file);
%read filename (one line at a time)
% do filtering
meandata = x' - mean(x);

%low pass filter - remove interference at 60 hz
[B, A] = butter(10,40/180);
lowpass=filtfilt(B,A,meandata);

[ B, A ] = butter( 4, 2 / 180, 'high' );
highPass = filtfilt( B, A, lowpass );

highPass_filtered{i}=highPass;

%feature extraction - lpc + (classifier used to compare lpc values)
feature=lpc(highPass, 12);
features_extracted{i}=feature(2:12);

end
fclose(fid);

fid=fopen('test500.txt'); %file that contains the names of data files for i=1:number_of_files
highPass_filtered_test=[];
features_extracted_test=[];
for i=1:477
file=fgetl(fid); %read filename (one line at a time)
% do filtering
load(file);
meandata = x' - mean(x);

%low pass filter - remove interference at 60 hz
[B, A] = butter(10,40/180);
lowpass=filtfilt(B,A,meandata);

[ B, A ] = butter( 4, 2 / 180, 'high' );
highPass = filtfilt( B, A, lowpass );

highPass_filtered_test{i}=highPass;

%feature extraction - lpc + (classifier used to compare lpc values)
feature=lpc(highPass, 12);
features_extracted_test{i}=feature(2:12);

end
fclose(fid);

%creating empty target array to be appendid later.
target=[];
for i=0:476
    %appending to the array, creates 477 entries of 0-7
target = [target; mod( i, 8 )];
end
target=target';
train=features_extracted;
test=features_extracted_test;

%transforms cells to mat in order to access contents
trainm=reshape(cell2mat(train),[11,length(train)]);
testm=reshape(cell2mat(test),[11,length(test)]);

%calculates distance between train and test data into one array called
%Edist
for i=1:length(trainm)
Edist=sqrt(sum((trainm(:,i)-testm).*(trainm(:,i)-testm)));
end

%combines target data with Edist data into a 477x2 array
Et=[Edist; target]

%transposes the data
Et=Et';

%sorts the rows
sortEt=sortrows(Et)

%chose k=21 as it was the square root of 477 and k tends to be odd
k=21;
%creating empty counts so i can add subjects to each count to work out
%which ecg belongs to which subject.
counta=0;
countb=0;
countc=0;
countd=0;
counte=0;
countf=0;
countg=0;
counth=0;
%for loop goes through each data point, from 0-477, chose 456 as k is lenth
%21, and by applying sortEt(k:k+1,2) it would go out of the range the
%moment it hit 456
for i=1:456
predicted_class=mode(sortEt(k:k+i,2))%finds mode by splitting sorted data into chunks of 21.
if(predicted_class==0)%checks to see if predicted class==0 and if so adds to count.
    counta=counta+1;
else if (predicted_class==1)
        countb=countb+1;
    else if (predicted_class==2)
           countc=countc+1;
            else if (predicted_class==3)
                    countd=countd+1;
                else if (predicted_class==4)
                        counte=counte+1;
                    else if (predicted_class==5)
                            countf=countf+1;
                        else if (predicted_class==6)
                                countg=countg+1;
                            else if (predicted_class==7)
                                    counth=counth+1;
                                end
                            end
                        end
                    end
                end
        end
    end
end
end

a=sortEt(:,2);
success=0;
for j=1:477
if (a(j)==target(j))
success(j)=1;
end
end
total=(sum(success)/477)*100