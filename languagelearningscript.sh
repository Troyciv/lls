#!/bin/bash
clear
#enter the file name of your spreadsheet here
calc_sheet_name="pt_vocabulary.ods"
#enter urls as preferred, seperated by a spacebar
URL="https://www.semantica-portuguese.com/wp-login.php https://www.google.com.br/imghp?hl=en&tab=wi&ei=wgMRVoCPDYHZsgHmhqToBA&ved=0CBIQqi4oAQ http://pt.forvo.com/languages/pt/ http://www.conjuga-me.net/ http://www.priberam.pt/dlpo/Default.aspx http://www.linguee.de/deutsch-portugiesisch http://www.aulete.com.br/esquina http://peterjc.com/wordmultisearch/#/search https://translate.google.com/#auto/pt"
script_path=${0%/*}

#if schleife nötig
#rm log.txt


#################################################################################################################################################
#START APPLICATIONS
#################################################################################################################################################

#launch Anki
    anki & $script_path/data/pt_vocabulary.csv >& /dev/null &
    pid_anki=$!

#launch LibreOffice-Calc
     if [ -n "$calc_sheet_name" ]
         then
         libreoffice --calc --nologo -o $script_path/data/$calc_sheet_name >& /dev/null &
         else
         libreoffice --calc --nologo -n $script_path/data/templates/template_pt_1.ots >& /dev/null &
     fi

#launch Chromium
     chromium-browser --user-data-dir="$script_path/data/browser/chromium" $URL >& /dev/null &
     pid_chromium=$!

#Loop to wait until window launched, get Xid
     unset xid_anki
     while [ -z "$xid_anki" ]
     do
         xid_anki=$(wmctrl -l | grep Anki | cut -d " " -f1)
     done
     echo "xid_anki $xid_anki" #contains 2 xid on startup, howto solve?
    
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

#window placement and renaming
      # wmctrl -i -r $xid_calc -b add,fullscreen -T LanguageLearningScript\ -\ $calc_sheet_name
      # wmctrl -i -r $xid_chromium -T LanguageLearningScript\ -\ Browser
echo "Start your language journey now!"
echo "LanguageLearningScript is brought to you by <ME>"
#################################################################################################################################################
#WAIT FOR INPUT
#################################################################################################################################################
echo "enter \"c\" to close all windows"
read close
while [ "$close" != "c" ]
    do
        echo "ERROR:unknown command"
        echo "type \"c\" to close all windows"
        read close
done
#################################################################################################################################################
#CLOSE APPLICATIONS
#################################################################################################################################################
clear
echo "...terminating LanguageLearningScript..."
unset run
#close Anki
      #run=$(ps | grep $pid_anki)
      #if [ -n "$run" ]
      #    then
      #        echo "...closing Anki..."
      #        wmctrl -i -c $xid_anki &
      #    else
      #        echo "...Anki not found (already closed manually?)"
      #fi
      #unset run
	  #kill $pid_anki
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
              #kill $pid_chromium
          else
              echo "...Chromium not found (already closed manually?)"
      fi
      unset run
wait
echo "...finished!"
exit 0
