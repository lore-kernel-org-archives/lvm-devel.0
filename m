From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:19:47 +0000
Subject: [PATCH 12/29] Add test for 'read' result
In-Reply-To: <725e7919102c477b04e9589a0c2b0f8004f68a74.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<725e7919102c477b04e9589a0c2b0f8004f68a74.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129201947.GX29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:16AM +0100, Zdenek Kabelac wrote:
> Static analyzer complains when read result is ignored.
 
Compiler should have complained too! Ack.

>  	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/%u/cmdline", pid);

/* FIXME Use generic read code. */

>  	if ((fd = open(buf, O_RDONLY)) > 0) {
> -		read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1);


Alasdair


