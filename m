From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 13 Mar 2010 04:18:27 +0000
Subject: [PATCH] Remove the double open with same mode
In-Reply-To: <ee77738483f149622d19.1268439476@localhost>
References: <ee77738483f149622d19.1268439476@localhost>
Message-ID: <20100313041826.GB7267@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 12, 2010 at 04:17:56PM -0800, Malahal Naineni wrote:
>  	if ((open("/dev/null", O_RDONLY) < 0) ||
> -	    (open("/dev/null", O_WRONLY) < 0) ||
>  	    (open("/dev/null", O_WRONLY) < 0))
>  		exit(EXIT_DESC_OPEN_FAILURE);

stdin, stdout, stderr

Alasdair


