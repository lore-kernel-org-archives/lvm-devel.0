From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:18:21 +0000
Subject: [PATCH 23/29] Add test and error message for failure case
In-Reply-To: <5383deb0c0a91b2eb3b1e57309eea5bc64fee8d2.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5383deb0c0a91b2eb3b1e57309eea5bc64fee8d2.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129211820.GG29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:27AM +0100, Zdenek Kabelac wrote:
> +	if (unlink(CLVMD_PIDFILE))
> +		log_sys_error("unlink", CLVMD_PIDFILE);

Ack.

Alasdair


