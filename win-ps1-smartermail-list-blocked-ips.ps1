<###
#     Lista os IPs bloqueados e realiza o desbloquio por país
#     Version 1.0
# 
#     author:   Luis Gustavo Marucco Lins Leal <contato@luisgustavo.dev>
#     doc:      https://mail.smartertools.com/Documentation/api#/topics/overview
#     date:     22-12-2020
###>

### DADOS DE ACESSO A API

$API = @{}; # Clear Memory
#$APIHost = 'localhost:9998';
$APIHost = 'mail.host.net';
$s = 's'; #For SSL connections add an 's'
$API = @{
   'authUserName' = 'sys-user'
   'authPassword' = 'pa.ss.wo.rd'
   'Method'       = 'POST'
   'ContentType'  = 'application/json'
   'URI'          = 'http' + $s + '://' + $APIHost + '/'
} 

<# ### #>


clear

Write-Host "--------------------------  DADOS DE ACESSO  ---------------------------" -F Yellow;
write-host $api.authUserName
write-host $api.authPassword
write-host $api.Method
write-host $api.ContentType
write-host $api.URI
Write-Host "------------------------------------------------------------------------" -F Yellow;
Write-Host ""

#
# DEFINE AS FUNCOES
#

function execmd ( $a, $b ) {  $API.uri = 'http' + $s + '://' + $APIHost + '/' + $b; $API.Method = $a; }

function UpdateURImethod ( $a, $b ) {  $API.uri = 'http' + $s + '://' + $APIHost + '/' + $b; $API.Method = $a; }

function UpdateURImethodEmail ( $a, $b, $mail ) {  $API.uri = 'http' + $s + '://' + $APIHost + '/' + $b + '' + $mail ; $API.Method = $a; }

function PrimaryAuth {
   $APIAuth = @{};
   $APIAuth = @{
       'Uri' = 'http' + $s + '://' + $APIHost + '/api/v1/auth/authenticate-user'
       'Body' = '{"username":"' + $API.authUserName + '","password":"' + $API.authPassword + '","language":null,"twoFactorCode":""}'
       };
   $Auth = Invoke-RestMethod -Uri $APIAuth.Uri -ContentType $API.ContentType -Body $APIAuth.Body -Method $API.Method

   # SERVER ADMIN AUTH TOCKEN
   $API.Remove('Headers');
   $API.Add('Headers', @{ 'Authorization' = "Bearer $($Auth.accessToken)" });

   #write-host 'Token =' $Auth.accessToken

   # REFRESH
   $API.Remove('Refresh');
   $API.Add('Refresh' , @{"token" = $($Auth.refreshToken)});

   # EXPERATION
   $API.Remove('accessTokenExpiration');
   [DateTime]$ATExp = $Auth.accessTokenExpiration;
   $API.Add('accessTokenExpiration', $ATExp);

   return $Auth
}

function RefreshAuthToken () {
   $APIRefresh = @{};
   $APIRefresh = @{
       'URI'   = 'http' + $s + '://' + $APIHost + '/api/v1/auth/refresh-token'
       'Method'= 'POST'
       'Body'  = $API.Refresh
   }
   $AuthRefresh = Invoke-RestMethod -Uri $APIRefresh.Uri -Body $APIRefresh.Body -Method $APIRefresh.Method

   # SERVER ADMIN AUTH TOKEN
   $API.Remove('Headers');
   $API.Add('Headers', @{ 'Authorization' = "Bearer $($AuthRefresh.accessToken)" });

   # REFRESH
   $API.Remove('Refresh');
   $API.Add('Refresh' , @{"token" = $($AuthRefresh.refreshToken)});

   # EXPERATION
   $API.Remove('accessTokenExpiration');
   [DateTime]$ATExp = $Auth.accessTokenExpiration;
   $API.Add('accessTokenExpiration', $ATExp);

   return $AuthRefresh
}

function CheckForExpieredToken () {

       ### VERIFICA SE EXPIROU O TOKEN E FAZ REFRESH

       if ( $API.accessTokenExpiration -le (Get-Date) ) {
           $tRefresh = RefreshAuthToken; $tRefresh
           [DateTime]$ATExp = $tRefresh.accessTokenExpiration; $ATExp;
       }
}


# ============================================================================================= #
#  LISTA IPs BLOQUEADOS
# ============================================================================================= #
function listaIP () {  
        
    $user = PrimaryAuth

    $service = '"SMTP","IMAP", "POP"';
    #$service = '"IMAP"';
    $sort = "IP";

    $APIUpdate = @{};
    $APIUpdate = @{
        'Uri' = 'http' + $s + '://' + $APIHost + '/api/v1/settings/sysadmin/blocked-ips' 
        'Method'= 'POST'
        'body' = '{
            "serviceTypes":[' + $service + '],
            "sortType": "' + $sort + '"
        }'
    };
    

    $Auth = Invoke-RestMethod -Uri $APIUpdate.Uri -ContentType $API.ContentType    -Method $APIUpdate.Method  -Headers $API.Headers -Body $APIUpdate.body;

    # IMPRIMMI A RELAÇÃO DE IP´S
    # Write-Host $Auth.ipBlocks.ip + ' - ' + $Auth.ipBlocks.ipLocation

    # SERVER ADMIN AUTH TOCKEN
    $API.Remove('Headers');
    $API.Add('Headers', @{ 'Authorization' = "Bearer $($user.accessToken)" });
        
    # REFRESH
    $API.Remove('Refresh');
    $API.Add('Refresh' , @{"token" = $($user.refreshToken)});

    # EXPERATION
    $API.Remove('accessTokenExpiration');
    [DateTime]$ATExp = $user.accessTokenExpiration;
    $API.Add('accessTokenExpiration', $ATExp);


#    $ipBloqueado = '148.69.240.107' 
#
#    UpdateURImethod 'POST' '/api/v1/settings/sysadmin/unblock-ips'
#    $ipToRemove = $($Auth.ipBlocks.Where{$_.ip -eq $ipBloqueado } | ConvertTo-Json);
#
#    $APIUpdate = @{
#        'body-unblock' =  '{"ipBlocks":[' + $ipToRemove + ']}'
#    }
#
#    $unblock = Invoke-RestMethod -Uri $API.Uri  -ContentType $API.ContentType  -Method $API.Method  -Body $APIUpdate.'body-unblock' -Headers $API.Headers ;
#
#    $unblock

    
    #$pathToOutputFile = '/Users/luisgustavoleal/Nextcloud/Documents/_smartermail/ipbloqueado.txt'
    #$objIP =  $Auth.ipBlocks 
    #$objIP | Out-File $pathToOutputFile
    

    return $Auth.ipBlocks #.ip + ' - ' + $Auth.ipBlocks.ipLocation # Return IPs list blocked.
    

}


# ============================================================================================= #
#  DESBLOQUEIA IPs 
# ============================================================================================= #

function unlockIP ( $ipBloqueado ) {  
        
    #Write-Host $ipBloqueado

    $user = PrimaryAuth

    $service = '"SMTP","IMAP", "POP"';
    #$service = '"IMAP"';
    $sort = "IP";

    $APIUpdate = @{};
    $APIUpdate = @{
        'Uri' = 'http' + $s + '://' + $APIHost + '/api/v1/settings/sysadmin/blocked-ips' 
        'Method'= 'POST'
        'body' = '{
            "serviceTypes":[' + $service + '],
            "sortType": "' + $sort + '"
        }'
    };
    

    $Auth = Invoke-RestMethod -Uri $APIUpdate.Uri -ContentType $API.ContentType    -Method $APIUpdate.Method  -Headers $API.Headers -Body $APIUpdate.body;

    # SHOW LIST OF IP´S
    # Write-Host $Auth.ipBlocks.ip

    # SERVER ADMIN AUTH TOCKEN
    $API.Remove('Headers');
    $API.Add('Headers', @{ 'Authorization' = "Bearer $($user.accessToken)" });
        
    # REFRESH
    $API.Remove('Refresh');
    $API.Add('Refresh' , @{"token" = $($user.refreshToken)});

    # EXPERATION
    $API.Remove('accessTokenExpiration');
    [DateTime]$ATExp = $user.accessTokenExpiration;
    $API.Add('accessTokenExpiration', $ATExp);


    UpdateURImethod 'POST' '/api/v1/settings/sysadmin/unblock-ips'
    $ipToRemove = $($Auth.ipBlocks.Where{$_.ip -eq $ipBloqueado } | ConvertTo-Json);

    $APIUpdate = @{
        'body-unblock' =  '{"ipBlocks":[' + $ipToRemove + ']}'
    }

    $unblock = Invoke-RestMethod -Uri $API.Uri  -ContentType $API.ContentType  -Method $API.Method  -Body $APIUpdate.'body-unblock' -Headers $API.Headers ;

    #$unblock

    return $unblock #.ipBlocks.ip  # Return ip blocked.
    
}



# ============================================================================================= #
#  CRIAR LOG
# ============================================================================================= #

$LISTA = listaIP
#write-host $LISTA

$pasta_logs = "D:\SCRIPTS_PS\Logs\"
$nomeArquivoGeral = $APIHost+"ipbloqueado.txt"

# CREATE CSV TO SEARCH
#Out-file -Filepath ipbloqueado.csv -InputObject $LISTA -Encoding ascii -Width 50
Out-file -Filepath $pasta_logs$nomeArquivoGeral -InputObject $LISTA -Encoding ascii -Width 50
write-Host ""
write-Host ""
    
# ============================================================================================= #
#  PROCURA NA LISTA O PAIS (IPs) E DESBLOQUEIA
# ============================================================================================= #

Write-Host "----------------------- LIST OF IPs BLOCKEDS ----------------------" -F Yellow;
write-Host ""

# Name of country to unlock
$pais = "Portugal"


$string = Write-Output $LISTA
#$string

# Imprime as propriedades deste objeto
# $string | Get-Member   

# PERCORRE O OBJETO COMPARANDO SUA LOCALIZACAO COM A VARIAVEL PAIS

$contador = 0
$log = ""

$string | foreach-object {  

    if ($_.ipLocation -eq $pais) { 
        
        # CASO ENCONTRE, REALIZA DESBLOQUEIO
        write-host -f green $_.ip $_.ipLocation 

        # CHAMA FUNCAO DE DEBLOQUIO
        unlockIP $_.ip 
        $contador += 1
        $log += $_.ip + ";"

    }
    else { 
        
        write-host -f red $_.ip $_.ipLocation 
    }
}

# CRIA UM ARQUIVO DE LOG COM A DATA E HORA DE EXECUCAO;
$dataLog = Get-Date -uformat "%Y%m%d"
$horaLog = Get-Date -uformat "%H%M"
$nomeArquivo = "logDesbloqIP-" + $dataLog + $horaLog + ".txt"
Out-file -Filepath $pasta_logs$nomeArquivo -InputObject "$log" -Encoding ascii -Width 50

write-Host ""
Write-Host "------------------------------------------------------------------------" -F Yellow;
write-Host  "Total encontrados: " $contador -ForegroundColor Green -nonewline
write-Host ""
Write-Host "------------------------------------------------------------------------" -F Yellow;
write-Host ""
write-Host  "Arquivo de Log: " $nomeArquivo 
write-Host ""
write-Host ""
write-Host ""
    

# LEMBRETE
#
# Deixar os valores de serviços protocolos da funcao de desbloqueio igual da funcao de listar IP
#
