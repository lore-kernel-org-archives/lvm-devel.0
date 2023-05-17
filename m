From: Anton Lundin <glance@ac2.se>
Date: Wed, 17 May 2023 13:35:58 +0200
Subject: [PATCH] Fix header include for out of tree builds
In-Reply-To: <ddfeb159-4148-4aae-7760-0556ca3cda1d@redhat.com>
References: <20230516160511.2053800-1-glance@ac2.se>
 <ddfeb159-4148-4aae-7760-0556ca3cda1d@redhat.com>
Message-ID: <20230517113557.GD18946@accum.se>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 17 May, 2023 - Zdenek Kabelac wrote:

> Dne 16. 05. 23 v 18:05 Anton Lundin napsal(a):
> > The relative include didn't match up for out of tree builds. The
> > build tree include directory is in the include paths already.
> > 
> > Signed-off-by: Anton Lundin <glance@ac2.se>
> > ---
> > 
> > Now the following works:
> > $ mkdir lvm2-build
> > $ cd lvm2-build
> > $ ../lvm2/configure
> 
> Hi
> 
> Your bug is actually in this command:
> 
> configure --srcdir=XXXXX
> 
> > $ make
> > 
> 
> Otherwise srcdir is located in your builddir and you would actually get more
> errors in various parts of lvmb building - as we tend to use $(srcdir)
> inside makefiles..

I might be misunderstanding you. Are your comment about the fix or the
example on now to trigger the bug?

Just running configure from another directory will set srcdir
automatically. At least in any kind of modern auto-tools.


//Anton

