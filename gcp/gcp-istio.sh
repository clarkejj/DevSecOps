#!/bin/bash -e

# This creates within GCP an Istio cluster, described at https://wilsonmar.github.io/service-mesh
# This automates instructions at https://github.com/srinandan/istio-workshop#introduction
# and https://github.com/retroryan/istio-workshop/blob/master/exercise-1/README.md

# Instead of typing, copy this command to run in the console within the cloud:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-istio.sh)"
# by WilsonMar@gmail.com

# STATUS OF THIS: Just starting

# See  https://istio.io/docs/setup/kubernetes/quick-start-gke-dm/

# 1.1 Define variables:

   MY_PROJECT_ID="istio-by-wilsonmar"
   MY_APP_NAME="guestbook"  # for https://github.com/retroryan/istio-workshop/blob/master/exercise-1/README.md
   # "hello-istio"

# 1.2. Set Default Default Region and Zone:

   gcloud config set compute/zone   us-central1-c
   gcloud config set compute/region us-central1

# 1.3. Define project:

     # get your default project id:
   gcloud config get-value core/project

   gcloud config set project "$MY_PROJECT_ID"

# 1.4. Verify kubectl

   kubectl version

# 1.5 Start with a clean slate and delete all deployed services from the cluster:

   kubectl delete all --all

# 1.6. Enable the Compute Engine and Kubernetes Engine API: On Console: “APIs & Services” -> “Dashboard”

   gcloud services enable compute.googleapis.com container.googleapis.com


# 6. Prepare Kubernetes/GKE cluster 
   # Create cluster with https://cloud.google.com/kubernetes-engine/docs/concepts/alpha-clusters
    gcloud container clusters create "$MY_APP_NAME" \
    --machine-type=n1-standard-2 \
    --num-nodes=6 \
    --no-enable-legacy-authorization \
    --zone=us-west1-b \
    --cluster-version=1.9.7-gke.3

 # container lifecycle hooks in Kubernetes:
 # https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/

 # approximate the behavior of startup scripts using a DaemonSet with a 
 # simple pod that runs in privileged mode. For example code, see 
 # https://github.com/kubernetes/contrib/tree/master/startup-script.

# 7. Get credentials - Setup Kubernetes CLI Content:

   gcloud container clusters get-credentials hello-istio \
      --zone us-west1-b --project PROJECT_ID

# 8. grant cluster admin permissions to the current user. 
     #  these permissions create RBAC rules for Istio:

    kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)

   # Verify in GCP console.

# 9. Check Istio version:

   OS="$(uname)"
   if [ "x${OS}" = "xDarwin" ] ; then
     OSEXT="osx"
   else
     # TODO we should check more/complain if not likely to work, etc...
     OSEXT="linux"
   fi
   ISTIO_VERSION=$(curl -L -s https://api.github.com/repos/istio/istio/releases/latest | \
                  grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/")
   NAME="istio-$ISTIO_VERSION"
   URL="https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-${OSEXT}.tar.gz"

# 10. download and extract the latest Istio release: 

   # For pure Bourne shells: curl -L https://git.io/getLatestIstio | sh -   
   # Instead of: curl -L "$URL" | tar xz
   git clone https://github.com/istio/istio/releases/tag/0.8.0
   # TODO: change this so the version is in the tgz/directory name (users trying multiple versions)
   echo "Downloaded into $NAME:"
   ls "$NAME"
   BINDIR="$(cd "$NAME/bin" && pwd)"
   echo "Add $BINDIR to your path; e.g copy paste in your shell and/or ~/.profile:"
   echo "export PATH=\"\$PATH:$BINDIR\""
   cd ./istio-*

# 10. Add the istioctl client to your PATH:

   export PATH=$PWD/bin:$PATH

# 11. install Istio's core components. 
# install the Istio Auth components which enable mutual TLS authentication between sidecars:

# 12. Create the custom resource definitions 

   kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml

# 13. Create the helm service account 
 
   kubectl create -f install/kubernetes/helm/helm-service-account.yaml

# 14. Initialize helm:

   helm init --service-account tiller

# 15. Render Istio’s core components to a Kubernetes manifest called istio.yaml 

   helm template install/kubernetes/helm/istio --name istio --namespace istio-system > $HOME/istio.yaml 

# 16. install the helm client: https://docs.helm.sh/using_helm/

# 17. Install the components:

   kubectl create namespace istio-system
   
   kubectl apply -f $HOME/istio.yaml


# 18. Verify the installation:

   kubectl get svc -n istio-system


# 19. Run the command:

   kubectl get pods -n istio-system

# Sample app Bookinfo:
#  https://istio.io/docs/examples/bookinfo/
#  https://github.com/istio/istio/tree/master/samples/bookinfo


# 20. Get the ingress IP and port, as follows:

   kubectl -n istio-system get service istio-ingressgateway \
   -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 

# 21. set the GATEWAY_URL environment variable:

   export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# 22. Run the command:

   curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage

# 23. view the BookInfo web page:

   # open http://$GATEWAY_URL/productpage




#### Cleanup:

# 90. uninstall Istio:

   kubectl delete -f bookinfo/platform/kube/bookinfo.yaml

   kubectl delete -f $HOME/istio.yaml

# 91. Delete the Kubernetes cluster created in the setup phase (to save on cost and to be a good cloud citizen):

   gcloud container clusters delete hello-istio
      # OUTPUT:
      # The following clusters will be deleted. - [hello-istio] in [west1-b]
      # Do you want to continue (Y/n)?  Y
      # Deleting cluster hello-istio...done.


