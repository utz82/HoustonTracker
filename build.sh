#!/bin/sh

echo -n "Build for TI-82? (y/n/q) "
stty cbreak
readchar=`dd if=/dev/tty bs=1 count=1 2>/dev/null`
stty -cbreak
echo ""
if [ $readchar = "q" ]
then
exit
fi
if [ $readchar = "y" ]
then 
# Change the path below to point to your HoustonTracker directory relative to DOSBox' C: drive
dosbox -c "set target=ti82" -c "cd texasi~1\houston\htgit\Housto~1" -exit "as.bat"
rm ti82/MAIN.OBJ
tilem2 ti82/MAIN.82P
fi
echo -n "Build for TI-83? (y/n/q) "
stty cbreak
readchar=`dd if=/dev/tty bs=1 count=1 2>/dev/null`
stty -cbreak
echo ""
if [ $readchar = "q" ]
then
exit
fi
if [ $readchar = "y" ]
then 
# Change the path below to point to your HoustonTracker directory relative to DOSBox' C: drive
dosbox -c "cd texasi~1\houston\htgit\Housto~1" -c "set target=ti83" -exit "as.bat"
tilem2 ti83/MAIN.83P
fi
echo -n "Build for TI-83+/84+? (y/n/q) "
stty cbreak
readchar=`dd if=/dev/tty bs=1 count=1 2>/dev/null`
stty -cbreak
echo ""
if [ $readchar = "q" ]
then
exit
fi
if [ $readchar = "y" ]
then 
# Change the path below to point to your HoustonTracker directory relative to DOSBox' C: drive
dosbox -c "cd texasi~1\houston\htgit\Housto~1" -c "set target=ti8xp" -exit "as.bat"
rm ti8xp/MAIN.83P
tilem2 ti8xp/MAIN.8XP
fi
echo -n "Build for TI-73? (y/n/q) "
stty cbreak
readchar=`dd if=/dev/tty bs=1 count=1 2>/dev/null`
stty -cbreak
echo ""
if [ $readchar = "q" ]
then
exit
fi
if [ $readchar = "y" ]
then 
# Change the path below to point to your HoustonTracker directory relative to DOSBox' C: drive
dosbox -c "cd texasi~1\houston\htgit\Housto~1" -c "set target=ti73" -exit "as.bat"
rm ti73/MAIN.BIN
rm ti73/MAIN.LST
tilem2 ti73/MAIN.73P
fi
