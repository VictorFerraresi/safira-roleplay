// system_textdraws | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

hook OnGameModeInit(){
        blackScreen = TextDrawCreate(-20.000000,2.000000,"|");
        TextDrawUseBox(blackScreen,1);
        TextDrawBoxColor(blackScreen,0x000000ff);
        TextDrawTextSize(blackScreen,660.000000,22.000000);
        TextDrawAlignment(blackScreen,0);
        TextDrawBackgroundColor(blackScreen,0x000000ff);
        TextDrawFont(blackScreen,3);
        TextDrawLetterSize(blackScreen,1.000000,52.200000);
        TextDrawColor(blackScreen,0x000000ff);
        TextDrawSetOutline(blackScreen,1);
        TextDrawSetProportional(blackScreen,1);
        TextDrawSetShadow(blackScreen,1);

        return 1;
}
