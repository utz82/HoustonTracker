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
echo -n "Target ROM 19.006 (y/N) "
stty cbreak
readchar=`dd if=/dev/tty bs=1 count=1 2>/dev/null`
stty -cbreak
echo ""
if [ $readchar = "y" ]
then
dosbox -c "cd texasi~1\houston\htgit\Housto~1" -c "set target=r196" -exit "as.bat"
else
# Change the path below to point to your HoustonTracker directory relative to DOSBox' C: drive
dosbox -c "cd texasi~1\houston\htgit\Housto~1" -c "set target=ti82" -exit "as.bat"
fi
tilem2 ../HOUSTON.82P
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
rm ../temp.z80 >/dev/null
rm ../temp.lst >/dev/null
tilem2 ../HOUSTON.83P
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
tilem2 ../HOUSTON.8XP
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
rm ti73/MAIN.LST
tilem2 ../HOUSTON.73P
fi
