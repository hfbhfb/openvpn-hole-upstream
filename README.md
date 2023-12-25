

## 参考文档
https://github.com/nangongchengfeng/Kubernetes_Openvpn



## 基本使用
```bash

# 先获取集群 po service 的配置
kubectl get configmap kubeadm-config -n kube-system -o yaml

# 安装
make install

# 创建用户的函数
genclientkey(){
if [ $# -ne 3 ]
then
  echo "Usage: $0 <CLIENT_KEY_NAME> <NAMESPACE> <HELM_RELEASE>"
  exit
fi

KEY_NAME=$1
NAMESPACE=$2
HELM_RELEASE=$3
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
SERVICE_NAME=$(kubectl get svc -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
#SERVICE_IP=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o go-template='{{range $k, $v := (index .status.loadBalancer.ingress 0)}}{{$v}}{{end}}')
SERVICE_IP=render.tpddns.cn
kubectl -n "$NAMESPACE" exec -it "$POD_NAME" /etc/openvpn/setup/newClientCert.sh "$KEY_NAME" "$SERVICE_IP"
kubectl -n "$NAMESPACE" exec -it "$POD_NAME" cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" > "$KEY_NAME.ovpn"

}

# 创建用户
genclientkey "client1" "default" "openvpn1"

```


## 反向打洞：即在开发时，把服务部署在本地pc，k8s资源定义的service可以通过vpn连接到开发机器上来
1. 原理说明
   - 配置service，把服务名指向openvpn服务器
   - 通过sidecar的方式配置nginx的容器进行upstream指向

2. 需要把helm包做一些改造，增加sidecar的逻辑


