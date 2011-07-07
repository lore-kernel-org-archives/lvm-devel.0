From: ben <benscott@nwlink.com>
Date: Thu, 7 Jul 2011 15:01:39 -0700
Subject: --alloc seems to be ignored by lvextend
In-Reply-To: <20110707194049.GC7477@agk-dp.fab.redhat.com>
References: <201107071158.46782.benscott@nwlink.com>
	<20110707194049.GC7477@agk-dp.fab.redhat.com>
Message-ID: <201107071501.39342.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thursday, July 07, 2011 12:40:49 PM Alasdair G Kergon wrote:
> On Thu, Jul 07, 2011 at 11:58:46AM -0700, ben wrote:
> > When extending volumes with lvextend the allocation policy option --alloc
> > seems to be ignored. The policy remains unchanged.
> > 
> >   LVM version:     2.02.86(2)-cvs (2011-04-29)
> >   Library version: 1.02.65-cvs (2011-04-29)
> >   Driver version:  4.20.0
> 
> Specific example?
> 
> Alasdair
> 

An example:

bedroom:~/stuff# lvcreate --alloc normal --size 1g --name test newvg
  Logical volume "test" created

bedroom:~/stuff# lvs newvg
  LV   VG    Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test newvg -wn-a- 1.00g                                      

bedroom:~/stuff# lvextend --alloc anywhere --size +1g  newvg/test
  Extending logical volume test to 2.00 GiB
  Logical volume test successfully resized

It is still "normal" here:

bedroom:~/stuff# lvs newvg
  LV   VG    Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test newvg -wn-a- 2.00g                                      

bedroom:~/stuff# lvchange --alloc anywhere   newvg/test
  Logical volume "test" changed

Now it is "anywhere":

bedroom:~/stuff# lvs newvg
  LV   VG    Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test newvg -wa-a- 2.00g                                      


Adding a mirror leg has the same issue:

bedroom:~/stuff# lvcreate --alloc normal --size 1g --name test newvg
  Logical volume "test" created

bedroom:~/stuff# lvs newvg
  LV   VG    Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test newvg -wn-a- 1.00g                                      

bedroom:~/stuff# lvconvert --alloc anywhere --corelog --mirrors 1 newvg/test
  newvg/test: Converted: 0.0%
  newvg/test: Converted: 59.2%
  newvg/test: Converted: 67.2%
  newvg/test: Converted: 74.9%
  newvg/test: Converted: 82.7%
  newvg/test: Converted: 90.6%
  newvg/test: Converted: 98.2%
  newvg/test: Converted: 100.0%

bedroom:~/stuff# lvs newvg
  LV   VG    Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test newvg mwn-a- 1.00g                        100.00        

bedroom:~/stuff# lvchange --alloc anywhere   newvg/test
  Logical volume "test" changed

bedroom:~/stuff# lvs newvg
  LV   VG    Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test newvg mwa-a- 1.00g                        100.00        


