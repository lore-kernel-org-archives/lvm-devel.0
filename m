From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 21:55:37 +0200
Subject: [PATCH] Add escape sequence for ':' in command's PV list
In-Reply-To: <1242243809.2556.19.camel@f10-node1>
References: <4A0AAA51.8040609@redhat.com> <1242243809.2556.19.camel@f10-node1>
Message-ID: <4A0B25B9.70005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> +dev1_escaped=`echo $dev1 | awk '{ print substr($1,1,index($1,":")-1)"::"substr($1,index($1,":")+1) }'`

please can we somehow standardize which tools are required for testsuite?

or at least first test that the tools are available - like awk, mdadm, mke2fsck...

Milan


