echo "Setting up user ${CLUSTER_USER}"

if id -u $CLUSTER_USER > /dev/null 2>&1; then
	echo "User ${CLUSTER_USER} exists"
else
	echo "Creating user ${CLUSTER_USER}"
#	groupadd --gid $CLUSTER_GROUP_ID $CLUSTER_GROUP_NAME
	groupadd $CLUSTER_GROUP_NAME -g $CLUSTER_GROUP_ID
	useradd --no-user-group --uid $CLUSTER_USER_ID --gid $CLUSTER_GROUP_ID --shell /bin/bash --create-home $CLUSTER_USER
#	useradd -m -s /bin/bash -N -u $CLUSTER_USER_ID -g $CLUSTER_GROUP_ID $CLUSTER_USER --create-home $CLUSTER_USER
#  echo "${CLUSTER_USER}:${CLUSTER_USER}" | chpasswd
  usermod -aG sudo,adm,root $CLUSTER_USER
  chown -R $CLUSTER_USER:$CLUSTER_GROUP_NAME /home/$CLUSTER_USER
	echo "${CLUSTER_USER}   ALL = NOPASSWD: ALL" > /etc/sudoers

	touch /home/$CLUSTER_USER/.bashrc

	echo "User setup done"
fi

printf "\nsu - ${CLUSTER_USER}\n" >> ~/.bashrc

su $CLUSTER_USER




