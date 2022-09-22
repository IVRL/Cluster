# Quick start with RunAI
## General information

In this repo we will show you how to use runai and kubernetes to run your own or pre-made Docker images on the **EPFL cluster**.

**Docker** images are environments that fully encompass everything needed to run a certain application and are decoupled from the host system.
You can find more information on docker images using the following [link](https://docs.docker.com/get-started/overview/)

**Kuberenetes** is a management and deployment tool for docker images (containers). In our case it manages the deployment of images on the EPFL cluster.
More information on Kubernetes [here](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)

Finally, **RunAI** is a scheduler built on top of Kubernetes that allows you to submit jobs to ICCluster. 
More about RunAI [here](https://docs.run.ai/Researcher/overview-researcher/)

TAs and supervisors should provide students with pre-made docker images whenever possible to avoid unnecessary duplication and delays.

## Important Disclaimer

Once you start using the EPFL cluster, the resources you use will be charged to the lab, and they cost a lot. To make sure we do not receive excessive bills please strictly control your cluster usage. Amongst other things:
* Only submit jobs that you will also use.
* No idle running: If you are finished with a session, terminate it.
* **Delete your jobs** when finished (even if the session already terminated) with `runai delete jobname` such as not to crowd the job list.

## Install RunAI CLI

Things to download and put in $PATH:

* runai https://github.com/run-ai/runai-cli/releases
* helm
  https://github.com/helm/helm/releases
  or brew install helm
* kubectl https://kubernetes.io/docs/tasks/tools/ (most probably already there if you were using Kubernetes before)

More on the RunAI CLI installation:
https://docs.run.ai/Administrator/Researcher-Setup/cli-install/

### Login

* Ask your supervisor to give you access to use
  RunAI [Asking for access](https://icitdocs.epfl.ch/display/clusterdocs/Getting+Started+with+RunAI+SAML). Choose Nicoletta Isaac
 (Assistant) Or Sabine Süsstrunk (Head of the unit) as the approver.
* Connect to <https://app.run.ai>. Use "Login with SSO" and make sure you can login (use "EPFL" as the workspace name).
* Download the config file: <https://icitdocs.epfl.ch/download/attachments/3211266/config> and place it in `~/.kube/` (which you have to mkdir yourself).
  If the download link changes, it is likely to be
  listed [here](https://icitdocs.epfl.ch/display/clusterdocs/Getting+Started+with+RunAI+SAML).
* In a console, to login to RunAI, run: `runai login`
* In a console, configure your default project with: `runai config project ivrl`
* Test if you see the lab's jobs `runai list jobs`

## Submitting Jobs

* To submit jobs to the cluster, you need to have your docker image uploaded to <https://ic-registry.epfl.ch>
* If you're a (semester-project/master-thesis) student, you should ask your supervisor to provide you the docker image.
* **You can find a list of existing images [here](./docker_images#existing-images)**
* You can submit jobs either using `runai submit` command or using `kubectl apply -f` command. If you're not familiar
  with Kubernetes yaml files we suggest you use the `runai submit` command.
* Once submitted, your job will be automatically assigned to a machine and will pull the docker image. Hence, your job will usually starts/runs a few minutes after being submitted. You can get more details on the status of your job using `runai describe job`

## Submit using "runai submit"

* Submit jobs with `runai submit` command [(doc)](https://docs.run.ai/Researcher/cli-reference/runai-submit/).
* You can use our [runai submit script](scripts/runai_submit_train.sh) to make life easier!
    * First, fill in `CLUSTER_USER`, `CLUSTER_USER_ID` in the script to match your user.
        - `CLUSTER_USER` is the user name of your GASPAR.
        - We can obtain your `CLUSTER_USER_ID` data in your people.epfl.ch page. Use your GASPAR to access the
          administrative data, and `CLUSTER_USER_ID` is in the `UID` field.
    * Then submit jobs like this:
        - `./runai_submit_train.sh ep-gpu-pod 1 "python hello.py"`
          Which creates a job named "ep-gpu-pod", **uses 1 GPU**, and runs `python hello.py`

        - `./runai_submit_train.sh ep-gpu-pod 0.5 "python hello_half.py"`
          Which creates a job named "ep-gpu-pod", receives **half of a GPUs memory** (2 such jobs can fit on one GPU!),
          and runs `python hello_half.py`

        - `./runai_submit_jupyter.sh ep-jupyter-pod 1`
          Which creates a job named "ep-jupyter-pod", receives **uses 1 GPU** and then runs `jupyter lab` on it.


* **Make sure to use your initials when naming your job**. If you're named John Smith, your job name should be something
  like `js-gpu-pod`

Here is how it uses the submit command:

```bash
runai submit $arg_job_name \
  -i $MY_IMAGE \
  --gpu $arg_gpu \
  --interactive \ # For training jobs remove this line.
  --pvc runai-pv-ivrldata2:/data \
  --pvc runai-ivrl-scratch:/scratch \
  --large-shm \
  -e CLUSTER_USER=$CLUSTER_USER \
  -e CLUSTER_USER_ID=$CLUSTER_USER_ID \
  -e CLUSTER_GROUP_NAME=$CLUSTER_GROUP_NAME \
  -e CLUSTER_GROUP_ID=$CLUSTER_GROUP_ID \
  --host-ipc \
  --command -- /bin/bash -c $arg_cmd
```

***Warning:*** Different shells parse strings differently. Our [runai submit script](scripts/runai_submit_train.sh)
script works properly if you're using [zsh](https://ohmyz.sh/) shell. If your job does not start successfully, try to
write your command (`python hello.py` in the above example) directly inside
the [runai submit script](scripts/runai_submit_train.sh) instead of passing it as an argument.

**Volume mounts**: The default volume mounts in the script are for IVRL (`runai-pv-ivrldata2` volume
and `runai-ivrl-scratch` volume). Please change them if you are in a different lab. You can get the list of available
volumes using the command `kubectl get pvc`

**Here is a list of handy runai commands:**

* List jobs in the lab: `runai list jobs`

* Find out the status of your job `runai describe job jobname`

* Stop running jobs with `runai delete jobname`. Also if you want to submit another job with the same name, you need to
  delete the existing one which occupies the name.

* View logs `runai logs jobname`. Add `--tail 64` to see 64 latest lines (or other number). If you want to find the
  token for your jupyter notebook use `runai logs | grep token`.

* Run an interactive console inside the container `runai bash jobname`. This is equivalent to ssh-ing into your job.

**Training vs interactive**: By default jobs are submitted in [*
training* mode](https://docs.run.ai/Researcher/Walkthroughs/walkthrough-train/), which means they can use GPUs beyond
the lab's quota (28GPUs at the moment), but can be stopped and restarted (so its worth checkpointing etc). Jobs can be
made *interactive* (non-preemptible) with the `--interactive` option of `runai submit`, but they will be stopped after
12 hours, and there is a limited number of those allowed in the lab, so please do not create more than one interactive
job simultaneously.

## Submit using "kubectl apply -f"

* Using Kebernetes you will have more freedom to configure your pods.
* You can find some sample yaml files under the [yaml_files](./yaml_files)
* To submit a job using your config file run `kubectl apply -f config.yaml`

### Defining your yaml config file

An example config file is shown in [yaml_file/interactive_pod.yaml](./yaml_files/jupyter_pod.yaml).

* First we specify the name of the pod and your epfl username. **Make sure to use your initials when naming your job**.
  If you're named John Smith, your job name should be something like `js-gpu-pod`
* If you want to submit a train job remove the line ` priorityClassName: "build"`

``` yaml
apiVersion: run.ai/v1
kind: RunaiJob
metadata:
  name: ??? # Name your pod. Start with your initials for example ep-pod-name
  labels:
    priorityClassName: "build" # Interactive Job if present, for Train Job REMOVE this line
    user: ??? # Your username
spec:
  template:
    metadata:
      labels:
        user: ???.??? # User e.g. firstname.lastname
```

* Next we set the scheduler we want to use. The IC cluster uses runai-scheduler at the momemnt.
* We can specify what kind of pod ang GPU type we want using `run.ai/type` option.

```yaml
spec:
  hostIPC: true
  schedulerName: runai-scheduler
  restartPolicy: Never # once it finishes, do not restart
  nodeSelector:
    run.ai/type: S8 # "S8" (CPU only), "G9" (Nvidia V100) or "G10" (Nvidia A100)
```

By default, the container only has access to its internal file system. To read or save some data, we will mount the ivrl
drives. This is achieved by adding this to your yaml config file:

* The claim names can be found by executing `kubectl get pvc` in your terminal.

```yaml
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: runai-pv-ivrldata2
  - name: ivrl-scratch
    persistentVolumeClaim:
      claimName: runai-ivrl-scratch
  - name: dshm
    emptyDir:
      medium: Memory
      sizeLimit: 4Gi # 4G shared memory allocated from memory.
      claimName: runai-ivrl-scratch
```

Then we specify the container related configs.

* `image`: Specify the docker image that you want to use
* `env`: Using this option we set environment variables inside the container. The variables listed here are necessary
  for the /opt/lab/setup.sh script to work properly.
* `workingDir`: sets the default directory in your container
* `command`, and `args`: This determines the first command that will be executed when the container starts.
  The `/opt/lab/setup.sh` script is intended to set your user information and give you sudo access in the pod. In this
  example we additionally start jupyter lab.

``` yaml
containers:
  - name: ubuntu ### Name your container (pretty arbitrary)
    image: ??? # The docker image file you want to use. It should be uploaded to ic-registry
    env:
      - name: CLUSTER_USER
        value: ??? # Your epfl username. put inside ""
      - name: CLUSTER_USER_ID
        value: ??? # Your epfl UID. put inside ""
      - name: CLUSTER_GROUP_NAME
        value: ??? # Your group name. put inside ""
      - name: CLUSTER_GROUP_ID
        value: ??? # Your epfl GID. put inside ""
    workingDir: /
    command: [ "/bin/bash", "-c" ]
    args: [ "source /opt/lab/setup.sh && jupyter lab --ip=0.0.0.0 --no-browser --notebook-dir=/scratch --allow-root" ]
    ports:
      - containerPort: 8888
        name: jupyter
```

Additionally, we can specify

* `cpu`: The minimum number of CPU cores required
* `memory`: The required amount of RAM
* `nvidia.com/gpu`: The required GPU count
* `volumeMounts`: Where to mount the volumes that we specified before

```yaml
imagePullPolicy: Always
resources:
  requests:
    cpu: 16
    memory: "64Gi"
  limits:
    nvidia.com/gpu: 0
volumeMounts:
  - mountPath: /dev/shm
    name: dshm
  - mountPath: /scratch
    name: ivrl-scratch
  - mountPath: /data
    name: data
```

### Useful Kubernetes commands

We can list, start and stop pods using the `kubectl` command

* `kubectl get pods` \- lists pods which currently exist
* `kubectl get pods --field-selector=status.phase=Running` \- lists pods which are currently running
* `kubectl apply -f pod_definition_file.yaml` \- creates a new pod according to your specification
* `kubectl delete pod pod_name` \- deletes your pod \(make sure you delete containers you don't use anymore\)
* `kubectl describe pod pod_name` \- shows information about a pod\, including the output logs\, useful to diagnose why
  things are not working\.
* `kubectl logs pod_name` \- output logs from a pod

## Create your working directory

The semester-project, master thesis, intern students, and research scholars all have to create a folder under `/scratch/students` and put
all of their files and codes there. The name of your folder should follow this pattern: `year-semester-type-username`,
where type is

* `sp` for semester project
* `mt` for master thesis
* `in` for intern students
* `rs` for research scholars

For example if I'm doing a semester project in year 2023 in the spring semester my folder should be
named `2023-spring-sp-pajouheshgar`.


**Important:** If you get permission denied error in your pod, try to check the owner of your files using `ls -all`.
The owner should be your user and not the root. To change the ownership you can use the command bellow:
* `sudo chown -R $CLUSTER_USER:$CLUSTER_GROUP_NAME your_directory`

where `$CLUSTER_USER` is your username and `$CLUSTER_GROUP_NAME` is the group name ("ivrl" in our case).


## Network communication - port forwarding

See the example [pod configuration for jupyter](./yaml_files/jupyter_pod.yaml). To connect to our container over the
network, first we need to expose the ports in our container configuration:

```yaml
ports:
  - containerPort: 8888
    name: jupyter
```

Once the container with exposed ports is running, we will make a tunnel from our local computer's port to the container'
s port
using ([Kubernetes port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/))
.

```
kubectl port-forward pod-name local_port:container_port
```

For example for jupyter:

```
kubectl port-forward ep-jupyter-pod-0-0 8899:8888
```

Then we can open jupyter at localhost:8899. To get the token to access the jupyter you can
execute `runai logs pod-name | grep token`.

**Important:** Only use jupyter inside your interactive pods. The interactive jobs will automatically shutdown after
around 12hours.

[comment]: <> (To shut down jupyter &#40;and the container with it&#41; from the web interface:)

[comment]: <> (* JupyterLab: select *File -> Quit* from the menu in the top-left)

[comment]: <> (* Jupyter Notebook: press the *Quit* button in the top right)

[comment]: <> (Jupyter will run forever if we do not close it. Therefore I recommend limiting it)

[comment]: <> (with [timeout]&#40;https://www.tecmint.com/run-linux-command-with-time-limit-and-timeout/&#41;. The following command will)

[comment]: <> (automatically shut down Jupyter after 4 hours:)

## Asking the admins for help

The cluster machines sometimes get stuck and need to be restarted, or there are bugs in RunAI. In these cases, we need
to ask the ICIT admins for help. To localize the problem, they need good diagnostic information from you.

The [detailed procedure can be found here](https://icitdocs.epfl.ch/display/clusterdocs/Good+hints+to+open+a+ticket).
Here is the copy of this procedure, so that you may view it outside of the EPFL network:

**To open a ticket, please send an email to support-icit@epfl.ch. For students not affiliated with the lab, please keep
at least one lab members in the copy.**

* Chose an explicit **subject**
* qualify your ticket by providing all the information useful to resolve your issue
* attach your **yaml file** or the **runai command** used to start your job
* attach job/pod's **log information** (replace `<lab>` by your lab name)
    * find your job/pod:
  ```
  $ runai list job -p <lab>
  $ kubectl get pods -n runai-<lab>
  ```
    * get job/pod's description
  ```
  $ runai describe job <job name> -p <lab>
  $ kubectl describe pod <pod name> -n runai-<lab>
  ```
    * get job/pod's log
  ```
  $ runai logs pod name> -p <lab>
  $ kubectl logs <pod name> -n runai-<lab>
  ```
* provide others log messages you can have

## Acknowledgement

This repo borrows heavily from [CVLab kubernetes guide](https://github.com/cvlab-epfl/cvlab-kubernetes-guide). We
simplified the guide from CVLab and removed the parts that are not relevant to the current cluster. If you find a
mistake, something is not working, you know a better way, or you need a new image to be built, please let us know or
open an issue here.
