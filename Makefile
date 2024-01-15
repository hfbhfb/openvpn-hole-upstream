


helmAppName=openvpn1

build-template:
	rm -Rf outdir-${helmAppName}
	helm template openvpn/ --namespace default --values ./values2.yaml --name-template ${helmAppName} --output-dir outdir-${helmAppName}

install:
	-kubectl apply -f cm-nginxsidecar.yaml #开发用反向指定远端
	-kubectl apply -f certs-pvc.yaml # 单独创建pvc并在负载中使用
	-helm install openvpn/ --namespace default --values ./values2.yaml --name-template ${helmAppName} 

uninstall:
	# kubectl delete -f certs-pvc.yaml # 默认不删除
	helm uninstall --namespace default ${helmAppName} 

helmpack:
	helm package openvpn
	helm repo index .

