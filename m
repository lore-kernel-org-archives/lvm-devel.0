From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 02 Mar 2011 20:34:39 +0100
Subject: [PATCH 2/2] Do not send random bytes in message
In-Reply-To: <8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>
	<8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
Message-ID: <4D6E9BCF.6040109@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.3.2011 19:09, Zdenek Kabelac napsal(a):
> Fixing few issues:
> 
> struct clvm_header contains 'char args[1]' - so adding '+ 1' here
> for the message length calculation is not correct - we end up with longer
> message where last byte is uninitialized and passed to write function.
> 
> xid and clintid are initialized to 0.
> 
> Memory allocation is checked for NULL - though it's not really clear what
> should happen in this case - so just log the message - probably it will 
> fail few moments later...
> 

Needs also updated arglen parameter - so attaching updated patch.

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0000-Do-not-send-random-bytes-in-message.patch
Type: text/x-patch
Size: 1722 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110302/e1f26eb4/attachment.bin>
