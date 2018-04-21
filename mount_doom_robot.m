%initialize data collection and sending
pub = rospublisher('/raw_vel');
sub_bump = rossubscriber('/bump');
ccel = rossubscriber('/accel');
msg = rosmessage(pub);


while 1 
    
   accel_msg = receive(ccel);
   
   %take into account pitch from raising suspension
   accel_msg.Data(1) = accel_msg.Data(1) - 0.285;
   
   bumpMessage = receive(sub_bump);
   
   %If the roll is above a certain threshold, turn left, if below, turn
   %right
   if accel_msg.Data(2) < .026
       msg.Data = [0.075, -0.075]
       send(pub,msg)
       pause(accel_msg.Data(2)*2)
   end
   if accel_msg.Data(2)>.026
       msg.Data = [-0.075, 0.075]
       send(pub,msg)
       pause(accel_msg.Data(2)*2)
   end
   
   accel_msg.Data
    
   %if the roll is low, and the pitch is above 0, go forward
   if abs(accel_msg.Data(2)) < 0.026
       if accel_msg.Data(1) > -0.05
           msg.Data = [.075, .075]
           send(pub,msg)
           pause(.75)
           msg.Data = [0, 0]
           send(pub,msg)
       end
   end
  
   %if the sensor is bumped, stop the robot
    if any(bumpMessage.Data)
        msg.Data = [0.0, 0.0];
        send(pub, msg);
        break;
    end
   
  
end
