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

# Put the Claude Code / Codex CLIs on the PATH, and keep LD_LIBRARY_PATH unset
# so JAX and PyTorch load the CUDA libs bundled in their own pip wheels.
if ! grep -q "ai-clis" /home/$CLUSTER_USER/.bashrc 2>/dev/null; then
	printf '\nexport PATH="/opt/ai-clis/.local/bin:$PATH"\nunset LD_LIBRARY_PATH\n' >> /home/$CLUSTER_USER/.bashrc
fi

su $CLUSTER_USER




