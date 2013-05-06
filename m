From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 06 May 2013 12:17:23 -0500
Subject: [PATCH] lvm2app: Add thin and thin pool lv creation V2
In-Reply-To: <5187D093.7080105@gmail.com>
References: <1367597312-7157-1-git-send-email-tasleson@redhat.com>
	<87k3ncck85.fsf@in.ibm.com> <5187CE2E.8060309@redhat.com>
	<5187D093.7080105@gmail.com>
Message-ID: <5187E5A3.3090300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/06/2013 10:47 AM, Zdenek Kabelac wrote:
> We already have the API 'explosion' for  lvs/pvs/vgs properties.
> So I think it could probably share the same principal for lvcreate attrs.

For API consistency we probably should use the same technique for
get/set proprieties like we do in other parts of the API, for some
reason when you mentioned more C++ like I went with a separate get/set
functions.  I've mentioned before that I don't like returning structures
by value because there is a potential link issues if the library and
client code compiled with different options:
-fpcc-struct-return/-freg-struct-return.

> I liked the 'X protocol' way of using string named fields - but then
> you lose compile time check whether you pass valid arguments...

We are going to lose compile time enforcement regardless if we want
generic get/set functionality.

Regards,
Tony


