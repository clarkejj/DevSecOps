# What is Terraform?
# Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing, popular service providers as well as custom in-house solutions.

# Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

# The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

# Key Features
# Infrastructure as Code
# Infrastructure is described using a high-level configuration syntax. This allows a blueprint of your datacenter to be versioned and treated as you would any other code. Additionally, infrastructure can be shared and re-used.

# Execution Plans
# Terraform has a "planning" step where it generates an execution plan. The execution plan shows what Terraform will do when you call apply. This lets you avoid any surprises when Terraform manipulates infrastructure.

# Resource Graph
# Terraform builds a graph of all your resources, and parallelizes the creation and modification of any non-dependent resources. Because of this, Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure.

# Change Automation
# Complex changesets can be applied to your infrastructure with minimal human interaction. With the previously mentioned execution plan and resource graph, you know exactly what Terraform will change and in what order, avoiding many possible human errors.

#Install Terraform
#Configure your Cloud Shell environment to use the Terraform by installing it with the appropriate package:
wget https://releases.hashicorp.com/terraform/0.11.9/terraform_0.11.9_linux_amd64.zip

# Unzip the downloaded package:
unzip terraform_0.11.9_linux_amd64.zip

# Set PATH environmental variable to Terraform binaries:
export PATH="$PATH:$HOME/terraform"
cd /usr/bin
sudo ln -s $HOME/terraform
cd $HOME
source ~/.bashrc

# Note: Terraform is distributed as a binary package for all supported platforms and architectures.
# Verifying the Installation
# After installing Terraform, verify the installation by checking that Terraform is available:

terraform

# You should see help output similar to this:

# Usage: terraform [--version] [--help] <command> [args]

# The available commands for execution are listed below.
# The most common, useful commands are shown first, followed by less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the other commands, please read the help and docs before usage.

# Common commands:
#    apply              Builds or changes infrastructure
#    console            Interactive console for Terraform interpolations
#    destroy            Destroy Terraform-managed infrastructure
#    env                Workspace management
#    fmt                Rewrites config files to canonical format
#    get                Download and install modules for the configuration
#    graph              Create a visual graph of Terraform resources
#    import             Import existing infrastructure into Terraform
#    init               Initialize a Terraform working directory
#    output             Read an output from a state file
#    plan               Generate and show an execution plan
#    providers          Prints a tree of the providers used in the configuration
#    push               Upload this Terraform module to Atlas to run
#    refresh            Update local state file against real resources
#    show               Inspect Terraform state or plan
#    taint              Manually mark a resource for recreation
#    untaint            Manually unmark a resource as tainted
#    validate           Validates the Terraform files
#    version            Prints the Terraform version
#    workspace          Workspace management

# All other commands:
#    debug              Debug output management (experimental)
#    force-unlock       Manually unlock the terraform state
#    state              Advanced state management

# Build Infrastructure
# With Terraform installed, you can dive right in and start creating some infrastructure.

# Configuration
# The set of files used to describe infrastructure in Terraform is simply known as a Terraform configuration. We're going to write our first configuration now to launch a single VM instance.

# The format of the configuration files is documented here. We recommend using JSON for creating configuration files.

# Create a configuration an instance.tf file with your favourite editor like vim, nano etc.:

nano instance.tf

# Add the following content in file, Make sure to replace <PROJECT_ID> with the GCP project ID:

resource "google_compute_instance" "default" {
  project      = "<PROJECT_ID>"
  name         = "terraform"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

# Ctrl + X to save the file.

# This is a complete configuration that Terraform is ready to apply. The general structure should be intuitive and straightforward.

# The "resource" block in the instance.tf file defines a resource that exists within the infrastructure. A resource might be a physical component such as an VM instance.

# The resource block has two strings before opening the block: the resource type and the resource name. For this lab the resource type is google_compute_instance and the name is terraform. The prefix of the type maps to the provider: google_compute_instance automatically tells Terraform that it is managed by the Google provider.

# Within the resource block itself is the configuration needed for the resource.

# Verify your new file has been added and that there are no other *.tf files in your directory, since Terraform loads all of them:
ls

# Initialization
# The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is terraform init. This will initialize various local settings and data that will be used by subsequent commands.

# Terraform uses a plugin-based architecture to support the numerous infrastructure and service providers available. Each "Provider" is its own encapsulated binary distributed separately from Terraform itself. The terraform init command will automatically download and install any Provider binary for the providers to use within the configuration, which in this case is just the Google provider.
terraform init

# The Google provider plugin is downloaded and installed in a subdirectory of the current working directory, along with various other bookkeeping files. You will see an "Initializing provider plugins" message. Terraform knows that you're running from a Google project and is getting Google resources.

# Downloading plugin for provider "google" (1.16.2)...

# The output specifies which version of the plugin is being installed, and suggests specifying this version in future configuration files to ensure that terraform init will install a compatible version.

# The terraform plan command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files.

terraform plan

# This command is a convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state. For example, terraform plan might be run before committing a change to version control, to create confidence that it will behave as expected.

# Note: The optional -out argument can be used to save the generated plan to a file for later execution with terraform apply.
# Apply Changes
# In the same directory as the instance.tf file you created, run terraform apply.
terraform apply

# This output shows the Execution Plan, which describes the actions Terraform will take in order to change real infrastructure to match the configuration. The output format is similar to the diff format generated by tools like Git.

# There is a + next to google_compute_instance.terraform, which means that Terraform will create this resource. Beneath that you'll see the attributes that will be set. When the value displayed is <computed>, it means that the value won't be known until the resource is created.

# Example Output:

# An execution plan has been generated and is shown below.
# Resource actions are indicated with the following symbols:
#  + create

# Terraform will perform the following actions:

#  + google_compute_instance.default
#      id:                                                  <computed>
#      boot_disk.#:                                         "1"
#      boot_disk.0.auto_delete:                             "true"
#      boot_disk.0.device_name:                             <computed>
#      boot_disk.0.disk_encryption_key_sha256:              <computed>
#      boot_disk.0.initialize_params.#:                     "1"
#      boot_disk.0.initialize_params.0.image:               "debian-cloud/debian-9"
#      boot_disk.0.initialize_params.0.size:                <computed>
#      boot_disk.0.initialize_params.0.type:                <computed>
#      can_ip_forward:                                      "false"
#      cpu_platform:                                        <computed>
#      create_timeout:                                      "4"
#      guest_accelerator.#:                                 <computed>
#      instance_id:                                         <computed>
#      label_fingerprint:                                   <computed>
#      machine_type:                                        "n1-standard-1"
#      metadata_fingerprint:                                <computed>
#      name:                                                "terraform"
#      network_interface.#:                                 "1"
#      network_interface.0.access_config.#:                 "1"
#      network_interface.0.access_config.0.assigned_nat_ip: <computed>
#      network_interface.0.access_config.0.nat_ip:          <computed>
#      network_interface.0.address:                         <computed>
#      network_interface.0.name:                            <computed>
#      network_interface.0.network:                         "default"
#      network_interface.0.network_ip:                      <computed>
#      network_interface.0.subnetwork_project:              <computed>
#      project:                                             "qwiklabs-gcp-e5726c3115b631fc"
#      scheduling.#:                                        <computed>
#      self_link:                                           <computed>
#      tags_fingerprint:                                    <computed>
#      zone:                                                "us-central1-a"

# Plan: 1 to add, 0 to change, 0 to destroy.

# Do you want to perform these actions?
#  Terraform will perform the actions described above.
#  Only 'yes' will be accepted to approve.

#  Enter a value:

# If the plan was created successfully, Terraform will now pause and wait for approval before proceeding. In a production environment, if anything in the Execution Plan seems incorrect or dangerous, it's safe to abort here. No changes have been made to your infrastructure.

# For this case the plan looks acceptable, so type yes at the confirmation prompt to proceed.

# Executing the plan will take a few minutes since Terraform waits for the VM instance to become available

# After this, Terraform is all done!

# Test Completed Task
# Click Check my progress to verify your performed task. If you have completed the task successfully you will granted with an assessment score.

# Create a VM instance in us-central1-a zone with Terraform.
# In the Console, go to Compute Engine > VM instances to see the created VM instance.

cf68a77143674661.png

# Terraform has written some data into the terraform.tfstate file. This state file is extremely important; it keeps track of the IDs of created resources so that Terraform knows what it is managing.

# You can inspect the current state using terraform show:
terraform show

# Example Output:

# google_compute_instance.default:
#  id = terraform
#  attached_disk.# = 0
#  boot_disk.# = 1
#  boot_disk.0.auto_delete = true
#  boot_disk.0.device_name = persistent-disk-0
#  boot_disk.0.disk_encryption_key_raw =
#  boot_disk.0.disk_encryption_key_sha256 =
#  boot_disk.0.initialize_params.# = 1
#  boot_disk.0.initialize_params.0.image = https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-9-stretch-v20180806
#  boot_disk.0.initialize_params.0.size = 10
#  boot_disk.0.initialize_params.0.type = pd-standard
#  boot_disk.0.source = https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-bc31fa8eb67d565b/zones/us-central1-a/disks/terraform
#  can_ip_forward = false
#....
# You can see that by creating this resource, you've also gathered a lot of information about it. These values can be referenced to configure additional resources or outputs.

# If you want to go review the execution plan after it's been applied, you can use terraform plan command:
terraform plan

# Congratulations! You've built your first infrastructure with Terraform. You've seen the configuration syntax, an example of a basic execution plan, and understand the state file.

# Test your Understanding
# Below are multiple choice questions to reinforce your understanding of this lab's concepts. Answer them to the best of your abilities.

# Terraform enables you to safely and predictably create, change, and improve infrastructure.  
# With Terraform we can create our own custom provider plugins.  
# Congratulations
