#!/bin/bash
clear
script_path=${0%/*}
#specify csv file for anki to open on startup
anki_csv="$script_path/data/pt_vocabulary.csv"
#specify the file LibreOffice-Calc should open on startup, file has to be in the scrpt-path
calc_sheet_name="pt_vocabulary.ods"
#enter urls as preferred, seperated by a spacebar / better to outsource in a config-file
URL="https://www.semantica-portuguese.com/wp-login.php file://${0%/*}/Multisearch/multisearch.html http://www.conjuga-me.net/" # http://www.priberam.pt/dlpo/Default.aspx http://www.linguee.de/deutsch-portugiesisch http://www.aulete.com.br/esquina http://peterjc.com/wordmultisearch/#/search https://translate.google.com/#auto/pt http://pt.forvo.com/languages/pt/ 
#########################################################################################################################
# START APPLICATIONS
#########################################################################################################################

#launch Anki
anki  & #$anki_csv ($script_path/data/pt_vocabulary.csv) >& /dev/null &
pid_anki=$!

#launch LibreOffice-Calc
if [ -n "$calc_sheet_name" ]
then
	libreoffice --calc --nologo -o $script_path/data/Calc/$calc_sheet_name >& /dev/null &
else
	libreoffice --calc --nologo -n $script_path/data/Calc/templates/template_pt_1.ots >& /dev/null &
fi

#launch Chromium
chromium-browser --user-data-dir="$script_path/data/browser/chromium" $URL >& /dev/null &
pid_chromium=$!

#Loop to wait until window launched, get Xid
#wmctrl -l
unset xid_anki
while [ -z "$xid_anki" ]
do
	xid_anki=$(wmctrl -l | grep Anki | cut -d " " -f1)
done
echo "xid_anki $xid_anki" #contains 2 xid when file to open specified on startup, howto solve?
#wmctrl -l
unset xid_calc
while [ -z "$xid_calc" ]
do
	xid_calc=$(wmctrl -l | grep $calc_sheet_name | cut -d " " -f1)
done
echo "xid_calc $xid_calc"
unset xid_chromium
while [ -z "$xid_chromium" ]
do
	xid_chromium=$(wmctrl -lp | grep $pid_chromium | cut -d " " -f1)
done
echo "xid_chromium $xid_chromium"
#echo "all window-IDs " && wmctrl -l

#window placement ideas: devilspie, wmctl, wmutils
#window placement and renaming
wmctrl -i -r $xid_calc -e 7,-1,-1,100,100, -b add,maximized_horz
# wmctrl -i -r $xid_chromium -T LanguageLearningScript\ -\ Browser
echo "Start your language journey now!"
echo "LanguageLearningScript is brought to you by <ME>"
###################################################################################################################
#WAIT FOR INPUT
###################################################################################################################
echo "enter \"q\" to close all windows"
read close
while [ "$close" != "q" ]
do
	echo "ERROR:unknown command"
	echo "type \"q\" to close all windows"
	read close
done
###################################################################################################################
#CLOSE APPLICATIONS
###################################################################################################################
#issue: mixed use of ps and wmctrl to check wheather window is still up
#clear
echo "...terminating LanguageLearningScript..."
unset run
#close Anki
run=$(ps | grep $pid_anki) #check wheather process is still up
if [ -n "$run" ]
    then
        echo "...closing Anki..."
        wmctrl -i -c $xid_anki &
    else
        echo "...Anki not found (already closed manually?)"
fi
unset run
#close LibreOffice
run=$(wmctrl -l | grep $calc_sheet_name)
if [ -n "$run" ]
then
	echo "...closing LibreOffice Calc..."
	wmctrl -i -c $xid_calc &
else
	echo "...LibreOffice Calc not found (already closed manually?)"
fi
unset run
#close Chromium
run=$(ps | grep $pid_chromium)
if [ -n "$run" ]
then
	echo "...closing Chromium..."
	wmctrl -i -c $xid_chromium
else
	echo "...Chromium not found (already closed manually?)"
fi
unset run
wait
echo "...all closed, see you next time."
exit 0
