From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:02:14 +0000
Subject: [PATCH 19/29] Test for error status
In-Reply-To: <a1f1654ee3bb7da4b0a538697fc3e60d4a63b63c.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<a1f1654ee3bb7da4b0a538697fc3e60d4a63b63c.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129210214.GE29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:23AM +0100, Zdenek Kabelac wrote:
> +		if (write(child_pipe[1], &status, sizeof(status)) < 0)
> +			log_sys_error("write", "child_pipe");

Still incomplete - add FIXME to use a proper wrapper around write().

> +		if (close(child_pipe[1]))
> +			log_sys_error("close", "child_pipe");

Ack.

Alasdair


