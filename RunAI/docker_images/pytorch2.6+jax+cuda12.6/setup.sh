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

USER_BASHRC=/home/$CLUSTER_USER/.bashrc

# Put the Claude Code / Codex CLIs on the PATH, and keep LD_LIBRARY_PATH unset
# so JAX and PyTorch load the CUDA libs bundled in their own pip wheels.
if ! grep -q "ai-clis" $USER_BASHRC 2>/dev/null; then
	printf '\nexport PATH="/opt/ai-clis/.local/bin:$PATH"\nunset LD_LIBRARY_PATH\n' >> $USER_BASHRC
fi

# The home directory is wiped together with the pod, so keep the CLI logins and
# session history on scratch instead. CLUSTER_SCRATCH_USER is the name of your
# folder under /scratch (e.g. "Ehsan" -> /scratch/Ehsan). Use the claude-rcp and
# codex-rcp aliases to get the persistent config; plain claude/codex stay
# ephemeral.
if [ -n "$CLUSTER_SCRATCH_USER" ] && [ -d /scratch ]; then
	SCRATCH_HOME=/scratch/$CLUSTER_SCRATCH_USER

	mkdir -p $SCRATCH_HOME/.claude-rcp $SCRATCH_HOME/.codex-rcp
	chown $CLUSTER_USER:$CLUSTER_GROUP_NAME $SCRATCH_HOME $SCRATCH_HOME/.claude-rcp $SCRATCH_HOME/.codex-rcp

	if ! grep -q "claude-rcp" $USER_BASHRC 2>/dev/null; then
		printf '\nalias claude-rcp="CLAUDE_CONFIG_DIR=%s/.claude-rcp claude"\nalias codex-rcp="CODEX_HOME=%s/.codex-rcp codex"\n' "$SCRATCH_HOME" "$SCRATCH_HOME" >> $USER_BASHRC
	fi

	echo "Persistent CLI config: ${SCRATCH_HOME}/.claude-rcp and ${SCRATCH_HOME}/.codex-rcp"
else
	echo "CLUSTER_SCRATCH_USER not set or /scratch not mounted: claude/codex config will not persist"
fi

su $CLUSTER_USER




