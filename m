From: Diego Elio Pettenò <flameeyes@gmail.com>
Date: Tue, 12 Oct 2010 14:26:38 -0000
Subject: [PATCH] Fix liblvm2cmd.so linking order for --as-needed builds
In-Reply-To: <4CB468E4.4080101@redhat.com>
References: <1283355456.30896.286.camel@yamato.local>
	<4CB468E4.4080101@redhat.com>
Message-ID: <1286893207.20493.20.camel@yamato.local>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Il giorno mar, 12/10/2010 alle 15.55 +0200, Zdenek Kabelac ha scritto:
> The last occurrence of  CLDWHOLEARCHIVE in tools/Makefile.in seems to be
> dropped by this Alasdair's commit:

Uh?

liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
        $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
        $(CFLAGS) $(CLDFLAGS) -o $@ $(LVMLIBS) $(LIBS) \
                @CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@

this is in 

commit 39429d390515de9a375979274bc61d787ea9a0cb
Author: Zdenek Kabelac <zkabelac@redhat.com>
Date:   Fri Oct 8 15:03:21 2010 +0000

Did I get the wrong GIT repository?


-- 
Diego Elio Petten? ? ?Flameeyes?
http://blog.flameeyes.eu/

If you found a .asc file in this mail and know not what it is,
it's a GnuPG digital signature: http://www.gnupg.org/

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 490 bytes
Desc: This is a digitally signed message part
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101012/07353e75/attachment.sig>
