/*



                        SISTEMA DE BITCOIN BY ZENYX SG
                        DISCORD: discord.gg/sampcode


*/



#include <YSI_Coding\y_hooks>

enum E_BITCOIN{
    Float:E_BITCOIN_VALOR,  //valor em reais   
    E_BITCOIN_ATUALIZACAO[64], //data
    Float:E_BITCOIN_ALTERACAO  //porcetagem alterada
};
new BitcoinData[E_BITCOIN];        
new Float:btcTemp[MAX_PLAYERS]; //apenas uma var de armazenar os bitcoin na confirmaçao de comprar
new valorReaisTemp[MAX_PLAYERS]; //mesma coisa de cima porem aqui armazenar o valor que é


//aqui vc deve por em sua pinfo para salvar o bitcoin do jogador;

new Float:saldoBitcoin[MAX_PLAYERS]; // btc dos cara


hook OnGameModeInit(){

    BitcoinData[E_BITCOIN_VALOR] = 500000;  
    BitcoinData[E_BITCOIN_ALTERACAO] = 0.0; 

    // Inicializando com uma data fictícia
    format(BitcoinData[E_BITCOIN_ATUALIZACAO], sizeof(BitcoinData[E_BITCOIN_ATUALIZACAO]), "Inicial"); //index
    return 1;
}

static stock Float:Obter_ValorBitcoin() 
    return BitcoinData[E_BITCOIN_VALOR];

static stock Obter_DinheiroJogador(playerid) 
    return GetPlayerMoney(playerid);

static stock Float:Obter_SaldoBitcoin(playerid) 
    return saldoBitcoin[playerid];

static stock SepararGrana(number){

    static
        value[32],
        length;

    format(value, sizeof(value), "%d", (number < 0) ? (-number) : (number));

    if ((length = strlen(value)) > 3){
        for (new i = length, l = 0; --i >= 0; l ++) {
            if ((l > 0) && (l % 3 == 0)) strins(value, ".", i + 1);
        }
    }
    if (number < 0)
        strins(value, "-", 0);

    return value;
}

static stock BitCoin_AtualizarData(){

    new ano, mes, dia, 
    hora, minuto, segundo;

    getdate(dia, mes, ano); 
    gettime(hora, minuto, segundo);

    format(BitcoinData[E_BITCOIN_ATUALIZACAO], sizeof(BitcoinData[E_BITCOIN_ATUALIZACAO]), "%02d/%02d/%04d %02d:%02d:%02d",
        dia, mes, ano, hora, minuto, segundo);

    return true;
}


CMD:comprarbtc(playerid)
{
    new 
        string[2*177+3];

    format(
            string, sizeof(string),

            "Ola jogador {00bfff}%s\n    {ffffff}deseja investir dinheiro em bitcoin?\n    aqui voce compra cotacoes para lucros futuros\n\nSeu Saldo Atual e de {00bfff}%s\n    {ffffff}O valor do bitcoin atual e de {00bfff}%.2f\n    {ffffff}Voce possui {00bfff}%.6f {ffffff}\
            de Bitcoin\n\n    Deseja realizar o investimento?\n    Se sim digite abaixo um valor abaixo, para que possamos calcular o valor",
            PlayerName(playerid),
            SepararGrana(Obter_DinheiroJogador(playerid)),
            Obter_ValorBitcoin(),
            saldoBitcoin[playerid]
        );

    Dialog_Show(playerid, DIALOG_COMPRAR_BTC, DIALOG_STYLE_INPUT, "Comprar Bitcoin", string, "Comprar", "Cancelar");
    return 1;
}
CMD:saldobtc(playerid){

    new string[350],
        saldoEmReais = 
        floatround(Obter_SaldoBitcoin(playerid) * 
        Obter_ValorBitcoin(), floatround_round); //converter o valor de 000.044 etcc em reais

    format(
        string, sizeof(string),
        "Observacao\tInformacao\n{00bfff}%.6f {ffffff}BitCoin(s)\tSaldo em R$ {00bfff}%s\n{ffffff}Ultima atualização: {00bfff}%s\n{ffffff}Alteracao BitCoin R$ {00bfff}%.2f\n{ffffff}Valor BitCoin {00bfff}%.2f",

        Obter_SaldoBitcoin(playerid), //bitcoin do jogador
        SepararGrana(saldoEmReais),  //somar o saldo que ele tem de btc
        BitcoinData[E_BITCOIN_ATUALIZACAO],   //vazio
        BitcoinData[E_BITCOIN_ALTERACAO],
        Obter_ValorBitcoin()
    );
    Dialog_Show(playerid, DIALOG_SALDO_BTC, DIALOG_STYLE_TABLIST, "Saldo de Bitcoin", string, "Fechar", "");
    return 1;
}
CMD:atualizarbtc(playerid)
{
    new string[2*150],
        minValue = 350000, //minimo
        maxValue = 800000, //maximo 
        Float:valorAnterior = Obter_ValorBitcoin();

    BitcoinData[E_BITCOIN_VALOR] = float(random(maxValue - minValue + 1) + minValue);
    BitcoinData[E_BITCOIN_ALTERACAO] = Obter_ValorBitcoin() - valorAnterior; //calcular o valor do anterior pro do atual

    BitCoin_AtualizarData();

    format(
        string, sizeof(string),
        "O valor do Bitcoin foi atualizado para: R$ {9a9a9a}%.2f {ffffff}Última atualização: {9a9a9a}%s{FFFFFF}Valor alterado R$ {00bfff}%.2f",
        Obter_ValorBitcoin(),
        BitcoinData[E_BITCOIN_ATUALIZACAO],
        BitcoinData[E_BITCOIN_ALTERACAO]
    );
    SendClientMessageToAll(-1, string);

    SendClientMessage(playerid, -1, "Bit coin atualizado o valor");
    return 1;
}
Dialog:DIALOG_COMPRAR_BTC(playerid, response, listitem, inputtext[])
{
    if (!response) return 1;

    valorReaisTemp[playerid] = strval(inputtext); 

    if (valorReaisTemp[playerid] <= 0)
        return SendClientMessage(playerid, -1, "Digite um valor válido.");

    btcTemp[playerid] = float(valorReaisTemp[playerid]) / Obter_ValorBitcoin(); //converter quando que da o valor em reais em btc 000.666 etcc

    new string[245];
    format(
        string, sizeof(string),
        "Você comprará %.6f BTC por R$ %s. Confirma a compra?",
        btcTemp[playerid],
        SepararGrana(valorReaisTemp[playerid])
    );

    Dialog_Show(playerid, DIALOG_CONFIRMAR_COMPRA, DIALOG_STYLE_MSGBOX, "Confirmar Compra", string, "Confirmar", "Cancelar");
    return 1;
}
//fim 
Dialog:DIALOG_CONFIRMAR_COMPRA(playerid, response, listitem, inputtext[])
{
    if (!response) return SendClientMessage(playerid, -1, "Compra cancelada.");

    saldoBitcoin[playerid] += btcTemp[playerid];
    GivePlayerMoney(playerid, -valorReaisTemp[playerid]);

    new string[245];
    format(
        string, sizeof(string),
        "Você comprou %.6f BTC por R$ %s.",
        btcTemp[playerid],
        SepararGrana(valorReaisTemp[playerid])
    );
    SendClientMessage(playerid, -1, string);

    return 1;
}

    /*
            Breve trarei a versão v2 mais complexa desse sistema
            deseja algum sistema? contate nossa equipe de dev da SA-MP CODE
    
    */
