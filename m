From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 13 Mar 2007 14:07:38 +0000
Subject: Re: striped LVM1 volumes
In-Reply-To: <45F6702F.4090803@redhat.com>
References: <45F6702F.4090803@redhat.com>
Message-ID: <20070313140738.GH29428@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 13, 2007 at 07:34:39PM +1000, David Robinson wrote:
> Below is a patch which corrects the problem. It removes the extra check 
> which causes the failure.
 
I don't want to remove checks like that.
Two possibilities:
  the check is being performed wrongly and needs fixing 
    - unlikely since it works with LVM2 metadata
  the LVM1 format metadata isn't being set up correctly
    - fix it in the format lvm1 code

Alasdair


