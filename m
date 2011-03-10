From: Frank Ch. Eigler <fche@redhat.com>
Date: Thu, 10 Mar 2011 10:24:21 -0500
Subject: endless loop in _free_vginfo
In-Reply-To: <20110310015624.GA8900@xander.lga.redhat.com> (James M. Leddy's
	message of "Wed, 9 Mar 2011 20:56:24 -0500")
References: <20110310015624.GA8900@xander.lga.redhat.com>
Message-ID: <y0msjuvvw0q.fsf@fche.csb>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

James M Leddy <james.leddy@redhat.com> writes:

> [...]
> Shouldn't it be this ?
>
> - 	while ((vginfo2 = primary_vginfo->next));
> + 	while ((vginfo2 = vginfo2->next));

Isn't that whole loop then equivalent to "vginfo2 = NULL;" ?


- FChE


