# Jumper
Esse programa interage com serviços de VPN do provedor IPVanish onde é necessário uma licença do IPVanish e tem como objetivo auxiliar na troca nós durante ataques de intrusão/redteam/bugbounty. Utilizando as credenciais da sua licença, o programa é capaz de configurar um tunel VPN e realizar a troca do mesmo com poucos comandos adotando um logtrack que contém informações de endereços IP de saída e horário para auxiliar na documentação dos teste.

Os arquivos de configuração da VPN dentro do diretório **nó** sofreram alterações para o correto funcionamento da ferramenta. 

Código foi testado em uma distribuição Kali Linux baseada em debian. 
- Debian 5.3.9-3kali1

## How Install

```
apt install jq curl  -y
git clone https://github.com/d34dfr4m3/Jumper.git

```

## Usage:
Para executar o programa é necessário antes inserir as credenciais da licença no diretório **/etc/openvpn/ipvanish/credentials.txt** em um arquivo em texto plano onde a primeira linha contém o usuário e a segunda a senha, por exemplo:

```
$ sudo cat /etc/openvpn/ipvanish/credentials.txt
yourEmailAccount@yourdomain.com
passwordForIpVanishAccount

```
Defina as permissões do arquivo **/etc/openvpn/ipvanish/credentials.txt** para 0400 da seguinte forma: 
```
sudo chmod 0400 /etc/openvpn/ipvanish/credentials.txt
```

Posteriormente a configuração da credencial, basta iniciar o programa da seguinte forma:

```
$ sudo ./jumper.sh
[!] Log Directory Checked
[!] File with credentials OK, ready to go
[-] No vpn tunel running, starting one right NOW
[**] Attempt to connect to IPVANISH using ipvanish-US-Atlanta-atl-a33
[***] Openvpn is running at PID 22904
[*] Configuring routes
[-] VPN Interface is: tun0
[*] Done!
[**] SUCCESS: Connect with X.X.X.X located at "United States" at 11/24/19_18:42:08
```

Caso já esteja com um túnel configurado e queira trocar de endereço IP basta executar novamente e responder à interação do programa da seguinte forma:

```
$ sudo ./jumper.sh 
[!] Log Directory Checked
[!] File with credentials OK, ready to go
[!!] IPVANISH IS ALREADY RUNNING PID 23952, WANT TO KILL?[Y/n]y
[!!] Killing 23952
[-] Interface to reset?eth0
[+] Cleaning tun routes
[!] Deleting route: 0.0.0.0/1 via 172.21.20.1 dev tun0
[!] Deleting route: 128.0.0.0/1 via 172.21.20.1 dev tun0
[!] Deleting route: 172.21.20.0/23 dev tun0 proto kernel scope link src 172.21.21.100
Killed old client process
[**] Attempt to connect to IPVANISH using ipvanish-NL-Amsterdam-ams-a05
[***] Openvpn is running at PID 24160
[*] Configuring routes
IFACE tun0
[-] VPN Interface is: tun0
[*] Done!
[**] SUCCESS: Connect with X.X.X.X located at "Netherlands" at 11/24/19_18:51:26
```

#### Logs 
É importante manter um registro dos endereços IP's que você utilizou e o horário que utilizou, os logs do jumper se encontram em **/var/log/ipvanish/logtrace**

```
$ sudo cat /var/log/ipvanish/logtrace  
[**] SUCCESS: Connect with X.X.X.X located at "United States" at 11/24/19_18:29:15
[**] SUCCESS: Connect with X.X.X.X located at "Netherlands" at 11/24/19_18:30:21
[**] SUCCESS: Connect with X.X.X.X located at "United States" at 11/24/19_18:42:08
[**] SUCCESS: Connect with X.X.X.X located at "Italy" at 11/24/19_18:47:23
[**] SUCCESS: Connect with X.X.X.X located at "Netherlands" at 11/24/19_18:51:26
```


## ToDo 
- Implementar uma feature de stop/kill, uma vez que o teste termina e não é mais necessário utilizar túnel. No cenário atual a unica forma é eliminando o processo e reconfigurando as rotas do sistema operacional.

