From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Oct 2015 11:50:35 +0100
Subject: [PATCH] dmeventd: compare dso name with "-"
In-Reply-To: <1445931417-9667-1-git-send-email-lzhong@suse.com>
References: <1445931417-9667-1-git-send-email-lzhong@suse.com>
Message-ID: <562F56FB.2070008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.10.2015 v 08:36 Lidong Zhong napsal(a):
> If the dso name is not set in client, then it will be replaced by "-".
> So the server should compare the dso name with "-" to decide whether
> it is set.

Hi

Tried to fix this differently:

https://www.redhat.com/archives/lvm-devel/2015-October/msg00163.html


Please let me know if this has fixed problem for you.
(dmevent_tool is from already 'dead' project  dmraid - so untested)

Regards

Zdenek


