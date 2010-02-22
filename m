From: Christine Caulfield <ccaulfie@redhat.com>
Date: Mon, 22 Feb 2010 15:11:10 +0000
Subject: [PATCH 1/2] Add "fake" cluster locking (local locking performed in clvmd) for testing.
In-Reply-To: <1266850526-31583-1-git-send-email-mbroz@redhat.com>
References: <1266850526-31583-1-git-send-email-mbroz@redhat.com>
Message-ID: <4B829E8E.709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 22/02/10 14:55, Milan Broz wrote:
> This patch introduces simple "cluster" locking, which basically
> simulates only one node to allow clvmd running even withou any cluster
> infrastucture.
>
> The puprose of this patch is to provide very simple testin environment
> for cluster locking.
> Basically the locking is performed from long-running clvmd process.
>
> Signed-off-by: Milan Broz<mbroz@redhat.com>
> ---
>   configure.in                |    1 +
>   daemons/clvmd/Makefile.in   |    4 +
>   daemons/clvmd/clvmd-comms.h |    7 ++
>   daemons/clvmd/clvmd-fake.c  |  191 +++++++++++++++++++++++++++++++++++++++++++
>   daemons/clvmd/clvmd.c       |   16 ++++-
>   5 files changed, 218 insertions(+), 1 deletions(-)
>   create mode 100644 daemons/clvmd/clvmd-fake.c
>


> +static int init_comms()
> +{
> +	struct  sockaddr_un addr;
> +
> +	listen_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
> +
> +	if (listen_fd<  0)
> +		return -1;
> +
> +	memset(&addr, 0, sizeof(addr));
> +	addr.sun_family = AF_UNIX;
> +	strcpy(addr.sun_path, SOCKET_PATH);
> +
> +	unlink(SOCKET_PATH);
> +	if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr))<  0) {
> +		DEBUGLOG("Can't bind to port: %s\n", strerror(errno));
> +		close(listen_fd);
> +		return -1;
> +	}
> +
> +	listen(listen_fd, 5);
> +
> +	/* Set Close-on-exec */
> +	fcntl(listen_fd, F_SETFD, 1);
> +
> +	return 0;


If you only need a a dummy FD then you might as well use /dev/null 
rather than opening a real socket.


> +#ifdef USE_FAKE
> +	if (!clops)
> +		if ((cluster_iface == IF_AUTO || cluster_iface == IF_FAKE)&&  (clops = init_fake_cluster())) {
> +			max_csid_len = FAKE_CSID_LEN;
> +			max_cluster_message = FAKE_MAX_CLUSTER_MESSAGE;
> +			max_cluster_member_name_len = MAX_CLUSTER_MEMBER_NAME_LEN;
> +			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to FakeCluster");
> +		}
> +#endif
>

Please don't add it to the auto-detect list, that will only cause 
confusion. Only enable fake if it's specified on the command-line.

Chrissie


