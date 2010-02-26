From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 26 Feb 2010 17:01:38 +0100
Subject: PATCH: Replace mlockall() with interal implementation
In-Reply-To: <4B87D947.4060300@redhat.com>
References: <4B87D947.4060300@redhat.com>
Message-ID: <4B87F062.8090407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Here is updated version of the patch, that keeps the old mlockall()
functionality available with lvm.conf configure option.

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: memory.patch
Type: text/x-patch
Size: 12349 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100226/becf9033/attachment.bin>
