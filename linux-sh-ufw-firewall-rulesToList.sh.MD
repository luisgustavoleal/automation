## Script para atualizar regras UFW baseado em uma lista de IPs de uma URL ou arquivo.

### Configuração
Supondo que você já tenha o ufw instalado, certifique-se de que o ufw não esteja habilitado;

```shell
# ufw status verbose
```

Se não estiver habilitado, a resposta deve ser, Status: Disable, se não, vamos desabilitá-lo;
```
# ufw disable
```

Limpe todas as regras existentes;
```
# ufw reset
```
Definir as regras default para negar entrada e permitir conexões de saída;
```
# ufw default deny incoming
# ufw default allow outgoing
```
Caso esteja acessando o servidor remotamente via SSH adicione 2 regras, antes de prosseguir para não perder o acesso.
```
# ufw allow from 192.168.1.0/24
# ufw allow ssh
```
Após as regras terem sidas adicionadas com sucesso, é hora de habilitar seu firewall;
```
# ufw enable
```

Você receberá um aviso dizendo que o "comando pode interromper as conexões ssh existentes." Já configuramos uma regra de firewall que permite conexões SSH, portanto não teremos problemas.
Você pode executar o ```# ufw status``` para ver as regras definidas.


### Agendamento
Sempre que o script for executado, ele adicionará novos endereços IP do Cloudflare, portanto, considere executar o script semanalmente para garantir que ele seja mantido atualizado.
O script pode ser executado automaticamente usando cron;
```
# crontab -e
```
e adicione o evento;
```
0 0 * * 1 /your/path/your-script.sh > /dev/null 2>&1
```


### Excluir regra
Caso necessite excluir alguma regra, em primeiro lugar obtenha uma lista numerada de todas as regras:
```
# ufw status numbered
```
em seguida, exclua a regra pelo número:
```
# ufw delete 34
```
