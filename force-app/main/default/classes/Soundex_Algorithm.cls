public class Soundex_Algorithm {

    public static String calculateSoundexCode(String name) {
        
        //Convert characters to uppercase
        name = name.toUpperCase();

		//1.Save the first letter        
        String firstChar = name.substring(0,1);
        String soundexCode;
        String currentCharCode;
        String previousCharCode;
        String firstCharCode;
        
        for(Integer i = 0; i < name.length(); i++) {
            
            String currentChar = name.substring(i, i+1);
            previousCharCode = currentCharCode;

            /*2.Map all occurrences of a, e, i, o, u, y, h, w. to zero(0)
            Replace all consonants (include the first letter) with digits
            Map B F P V - 1
            Map C G J K Q S X Z - 2
            Map D T - 3
            Map L - 4
            Map M N - 5
            Map R - 6*/

            if(currentChar == 'B' || currentChar == 'F' || currentChar == 'P' || currentChar == 'V') {
                currentCharCode = '1';
            } else if(currentChar == 'C' || currentChar == 'G' || currentChar == 'J' || currentChar == 'K' || currentChar == 'Q'
                      || currentChar == 'S' || currentChar == 'X' || currentChar == 'Z') {
                currentCharCode = '2';
            } else if(currentChar == 'D' || currentChar == 'T') {
                currentCharCode = '3';          
            } else if(currentChar == 'L') {
                currentCharCode = '4';
            } else if(currentChar == 'M' || currentChar == 'N') {
                currentCharCode = '5';
            } else if(currentChar == 'R') {
                currentCharCode = '6';
            } else if(currentChar == 'A' || currentChar == 'E' || currentChar == 'I' || currentChar == 'O' || currentChar == 'U'
                     || currentChar == 'H' || currentChar == 'W' || currentChar == 'Y') {
                currentCharCode = '0';
            }
            
            if(i == 0) {
                firstCharCode = currentCharCode;
                soundexCode = currentCharCode;
            } else if(currentCharCode != previousCharCode) {
                //3.Replace all adjacent same digits with one digit
                soundexCode += currentCharCode;
            }   
        }
        
        if(soundexCode != null) {
            
            //4.Remove all zeros
            soundexCode = soundexCode.remove('0');
           
            //5.If the saved letter's digit is the same as the resulting first digit, remove the digit (keep the letter)
            soundexCode = firstChar + soundexCode.removeStart(firstCharCode);
            /*if(firstCharCode == soundexCode.substring(0, 1)) {
                soundexCode = firstChar + soundexCode.removeStart(firstCharCode);
            }*/
            //6.Make the code exactly length 4 by padding with zeros or truncating the excess
            Integer soundexCodeSize = soundexCode.length();
            if(soundexCodeSize > 4) {
                soundexCode = soundexCode.substring(0, 4);
            } else if(soundexCodeSize < 4) {
                if(soundexCodeSize == 3) {
                    soundexCode += '0';
                } else if(soundexCodeSize == 2) {
                    soundexCode += '00';
                } else if(soundexCodeSize == 1) {
                    soundexCode += '000';
                } else if(soundexCodeSize == 0){
                    soundexCode = '0000';
                }
            }
        	return soundexCode;
        } else {
            return '';
        }
    }
}