From: Petr Rockai <prockai@redhat.com>
Date: Thu, 13 May 2010 21:29:13 +0200
Subject: [PATCH v2] Skip also special lvm devices in scan (if ignore suspended is used).
In-Reply-To: <4BEC1EBC.8040005@redhat.com> (Milan Broz's message of "Thu, 13
	May 2010 17:46:04 +0200")
References: <1273764262-15922-1-git-send-email-mbroz@redhat.com>
	<4BEC1EBC.8040005@redhat.com>
Message-ID: <871vdfbnxy.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Skip also special lvm devices in scan (if ignore suspended is used).
>
> This shoud avoid various races between dmeventd on multiple nodes
> in cluster where one node already repairing device and another
> run full scan and locks the device.

I don't know much about the details of scanning, but for all I can tell,
the patch looks good. It doesn't seem to make much sense to be scanning
mimages and as pointed out it can interfere with other operations and
generally cause lots of grief.

> Signed-off-by: Milan Broz <mbroz@redhat.com>
Acked-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


