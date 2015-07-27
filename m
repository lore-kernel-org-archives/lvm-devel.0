From: Ferenc Wagner <wferi@niif.hu>
Date: Mon, 27 Jul 2015 16:45:18 +0200
Subject: master - clvmd: Fix freeze if client dies holding locks.
In-Reply-To: <20150723222626.8A47A61043@fedorahosted.org> (Alasdair Kergon's
	message of "Thu, 23 Jul 2015 22:26:26 +0000 (UTC)")
References: <20150723222626.8A47A61043@fedorahosted.org>
Message-ID: <877fplwtfl.fsf@lant.ki.iif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair Kergon <agk@fedoraproject.org> writes:

> +		if (max_fd > FD_SETSIZE - 32) {
> +			fprintf(stderr, "WARNING: There are too many connections to clvmd.  Investigate and take action now!\n");
> + 			fprintf(stderr, "WARNING: Your cluster may freeze up if the number of clvmd file descriptors (%d) exceeds %d.\n", max_fd + 1, FD_SETSIZE);
> +		}

Just an outsider question: why do you use stderr here instead of some
generic logging function?  If clvmd is run as a daemon, stderr is
/dev/null, thus these messages are lost.
-- 
Thanks,
Feri.


