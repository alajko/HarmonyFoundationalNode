#VARIABLES#
AWS_ACCESS_KEY=""
AWS_SECRET_ACCESS_KEY=""
REGION=""
INSTANCE_IP=""
KEYS=""

function setup_aws_keys
{
    echo "Enter your AWS ACCESS KEY"
    read AWS_ACCESS_KEY
    echo "You entered: "$AWS_ACCESS_KEY
    echo "Enter your AWS SECRET ACCESS KEY"
    read AWS_SECRET_ACCESS_KEY
    #storing it to aws configure to make it easy to destroy 
    mkdir -p ~/.aws/
    touch ~/.aws/credentials
    echo "" >> ~/.aws/credentials
    echo "[profile harmony-foundational]" >> ~/.aws/credentials
    echo "aws_access_key_id = "$AWS_ACCESS_KEY" " >> ~/.aws/credentials
    echo "aws_secret_access_key = "$AWS_SECRET_ACCESS_KEY" " >> ~/.aws/credentials
}

function input_user_access_keys
{
    #Need check-if-exists logic, so that you don't ask again.
    echo "Enter the geography where you want to run the instance: us-west-1, us-east-1 etc:"
    read REGION
    echo "Have you entered your aws access key already [y/n]?"
    read AWSYES
    case $AWSYES in 
        yY][eE][sS]|[yY])
        echo "We will use credentials file from ~/.aws/credentials" ;;
        nN][oO]|[nN])
        setup_aws_keys ;;
    esac
}

function generate_new_keys
{
    echo "New keys would be generated in keys/harmony-foundation"
    echo "If they exist, you have option to use them again"
    mkdir -p "keys/"
    ssh-keygen -N '' -f keys/harmony-foundation
    KEYS="keys/harmony-foundation"
}
        
function use_default_keys 
{
    echo "Looks like you want to use your default ssh keys"
    echo "Please enter path to your private key [e.g. ~/.ssh/id_rsa]"
    read KEYS
    echo "You entered: "$KEYS
}

function setup_login_keys
{   
    read -r -p "Do you want to use your default ssh keys? [Y/n]  " input
    case $input in 
        yY][eE][sS]|[yY])
        use_default_keys;;
        nN][oO]|[nN])
        generate_new_keys ;;
    esac
    
}

function provision_terraform
{   
    echo "Setting up your AWS INSTANCE ..."
    region='aws_region='$REGION
    terraform apply -var=$region -auto-approve
    rm -f local_config.txt
    terraform output ip
    terraform output ip | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> local_config.txt
    INSTANCE_IP=$(head -n 1 local_config.txt)
    echo "Your IP is: "$INSTANCE_IP
    terraform output private_key >> local_config.txt
    echo $region >> local_config.txt
}

function instance_login
{   
    echo "Logging into your instance .."
    INSTANCE_IP=$(head -n 1 local_config.txt)
    KEYS=$(head -2 local_config.txt | tail -1)
    target="ec2-user@"$INSTANCE_IP
    echo "Running a Node on Remote Server.."
    sleep 2
    ssh -t -i  $KEYS $target 'tmux new  -d -s nodeRun "~/node.sh -S -t -p empty.txt"'
    ssh -i $KEYS $target
}

function create
{
   input_user_access_keys
   setup_login_keys
   provision_terraform
   instance_login  
}

function launch 
{
    create
}

function destroy
{   
    region=$(cat local_config.txt | head -3 | tail -1 )
    terraform destroy -auto-approve -var=$region
}

ACTION=$1

if [ -z "$ACTION" ]; then
   ACTION=launch
fi

case $ACTION in
   usage)
        show ;;
   launch)  
         create ;;
   shutdown)
         destroy ;;
   login)
         instance_login ;;
esac

exit 0
