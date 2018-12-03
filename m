From: David Teigland <teigland@redhat.com>
Date: Mon, 3 Dec 2018 11:22:21 -0600
Subject: master - scan: md metadata version 0.90 is at the end of disk
In-Reply-To: <5C049856020000F9000458D1@prv1-mh.provo.novell.com>
References: <201811291836.wATIaSVc015670@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5C049856020000F9000458D1@prv1-mh.provo.novell.com>
Message-ID: <20181203172221.GA6362@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Dec 02, 2018 at 07:43:34PM -0700, Gang He wrote:
> Hello David,
> 
> This patch can be used to fix this problem, or not?
> https://www.redhat.com/archives/linux-lvm/2018-October/msg00049.html 

On the stable branch there are three recent commits to fix/improve
md component detection.  I hope these will close any remaining gaps
in this area, let me know how these work.

scan: md metadata version 0.90 is at the end of disk
https://sourceware.org/git/?p=lvm2.git;a=commit;h=0e42ebd6d4012d210084a9ccf8d76f853726de3c

pvscan lvmetad: use full md filter when md 1.0 devices are present
https://sourceware.org/git/?p=lvm2.git;a=commit;h=a01e1fec0fe7c2fa61577c0e636e907cde7279ea

pvscan lvmetad: use udev info to improve md component detection
https://sourceware.org/git/?p=lvm2.git;a=commit;h=a188b1e513ed5ca0f5f3702c823490f5610d4495


