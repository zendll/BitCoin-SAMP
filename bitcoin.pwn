#include <YSI_Coding\y_hooks>

enum E_BITCOIN{
    Float:E_BITCOIN_VALOR,         
    E_BITCOIN_ATUALIZACAO[64],
    Float:E_BITCOIN_ALTERACAO  
};
new BitcoinData[E_BITCOIN];        
new Float:btcTemp[MAX_PLAYERS];
new valorReaisTemp[MAX_PLAYERS];

new Float:saldoBitcoin[MAX_PLAYERS]; // btc dos cara


hook OnGameModeInit(){

    BitcoinData[E_BITCOIN_VALOR] = 1000;  
    BitcoinData[E_BITCOIN_ALTERACAO] = 0.0; 

    // Inicializando com uma data fictícia
    format(BitcoinData[E_BITCOIN_ATUALIZACAO], sizeof(BitcoinData[E_BITCOIN_ATUALIZACAO]), "Inicial");
    return 1;
}
CMD:comprarbtc(playerid)
{
    new string[470],
        din = GetPlayerMoney(playerid);

    format(
            string, sizeof(string),

            "Ola jogador {00bfff}%s\n    {ffffff}deseja investir dinheiro em bitcoin?\n    aqui voce compra cotacoes para lucros futuros\n\n    Seu Saldo Atual e de {00bfff}%d\n    {ffffff}O valor do bitcoin atual e de {00bfff}%.2f\n    {ffffff}Voce possui {00bfff}%.6f {ffffff}\
            de Bitcoin\n\n    Deseja realizar o investimento?\n    Se sim digite abaixo um valor abaixo, para que possamos calcular o valor",
            PlayerName(playerid),
            din,
            BitcoinData[E_BITCOIN_VALOR],
            saldoBitcoin[playerid]
        );

    Dialog_Show(playerid, DIALOG_COMPRAR_BTC, DIALOG_STYLE_INPUT, "Comprar Bitcoin", string, "Comprar", "Cancelar");
    return 1;
}
CMD:saldobtc(playerid){

    new string[350],
        saldoEmReais = 
        floatround(saldoBitcoin[playerid] * 
        BitcoinData[E_BITCOIN_VALOR], floatround_round);

    format(
        string, sizeof(string),
        "Observacao\tInformacao\n{00bfff}%.6f {ffffff}BitCoin(s)\tR$ {00bfff}%d\n{ffffff}Ultima atualização: {00bfff}%s\n{ffffff}Valor Alterado: R$ {00bfff}%.2f",

        saldoBitcoin[playerid], //bitcoin do jogador
        saldoEmReais,  //somar o saldo que ele tem de btc
        BitcoinData[E_BITCOIN_ATUALIZACAO],  
        BitcoinData[E_BITCOIN_ALTERACAO]  
    );
    Dialog_Show(playerid, DIALOG_SALDO_BTC, DIALOG_STYLE_TABLIST, "Saldo de Bitcoin", string, "Fechar", "");
    return 1;
}
CMD:atualizarbitcoin(playerid)
{
    new string[244],
        minValue = 350000,
        maxValue = 800000,
        Float:valorAnterior = BitcoinData[E_BITCOIN_VALOR];

    BitcoinData[E_BITCOIN_VALOR] = float(random(maxValue - minValue + 1) + minValue);
    BitcoinData[E_BITCOIN_ALTERACAO] = BitcoinData[E_BITCOIN_VALOR] - valorAnterior; //calcular o valor do anterior pro do atual

    new ano, mes, dia, hora, minuto, segundo;
    getdate(dia, mes, ano); 
    gettime(hora, minuto, segundo);

    format(BitcoinData[E_BITCOIN_ATUALIZACAO], sizeof(BitcoinData[E_BITCOIN_ATUALIZACAO]), "%02d/%02d/%04d %02d:%02d:%02d",
        dia, mes, ano, hora, minuto, segundo);

    format(
        string, sizeof(string),
        "O valor do Bitcoin foi atualizado para: R$ {9a9a9a}%.2f {ffffff}Última atualização: {9a9a9a}%s{FFFFFF}Valor alterado R$ {00bfff}%.2f",
        BitcoinData[E_BITCOIN_VALOR],
        BitcoinData[E_BITCOIN_ATUALIZACAO],
        BitcoinData[E_BITCOIN_ALTERACAO]
    );
    SendClientMessageToAll(-1, string);
    return 1;
}


Dialog:DIALOG_COMPRAR_BTC(playerid, response, listitem, inputtext[])
{
    if (!response) return 1;

    valorReaisTemp[playerid] = strval(inputtext); 

    if (valorReaisTemp[playerid] <= 0)
        return SendClientMessage(playerid, -1, "Digite um valor válido.");

    btcTemp[playerid] = float(valorReaisTemp[playerid]) / BitcoinData[E_BITCOIN_VALOR];

    new string[245];
    format(
        string, sizeof(string),
        "Você comprará %.6f BTC por R$ %d. Confirma a compra?",
        btcTemp[playerid],
        valorReaisTemp[playerid]
    );

    Dialog_Show(playerid, DIALOG_CONFIRMAR_COMPRA, DIALOG_STYLE_MSGBOX, "Confirmar Compra", string, "Confirmar", "Cancelar");
    return 1;
}

Dialog:DIALOG_CONFIRMAR_COMPRA(playerid, response, listitem, inputtext[])
{
    if (!response) return SendClientMessage(playerid, -1, "Compra cancelada.");

    saldoBitcoin[playerid] += btcTemp[playerid];
    GivePlayerMoney(playerid, -valorReaisTemp[playerid]);

    new string[245];
    format(
        string, sizeof(string),
        "Você comprou %.6f BTC por R$ %d.",
        btcTemp[playerid],
        valorReaisTemp[playerid]
    );
    SendClientMessage(playerid, -1, string);

    return 1;
}