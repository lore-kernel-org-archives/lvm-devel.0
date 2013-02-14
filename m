From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 14 Feb 2013 14:18:09 +0100
Subject: [linux-lvm] create physical partition from logical partition
In-Reply-To: <51180903.4020108@redhat.com>
References: <CAMugGiGoVAKVTXHrcTwLOkiGCOF_iK5BsGKPo-5bHhXiC-f4tg@mail.gmail.com>
	<5113A5D5.3070808@redhat.com>
	<CAMugGiHnARz60km5=0WjHw4UrNnfvFVWQ3zgVWWG=n62S_XzNQ@mail.gmail.com>
	<5114BA25.2000108@redhat.com>
	<CAMugGiGTdn9SMjoaP2=AmPZ-QQuREVC89cziN4bM0eya5HjEDQ@mail.gmail.com>
	<51180903.4020108@redhat.com>
Message-ID: <511CE411.1030606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello, I did answer here and it still applies.

Though I am sure I have not got you an ill advice, please, *use reply to 
list* or reply to all, so other can review, fix typos/mistakes in steps, 
or provide an additional information.

 > [root at zaphod ~]# lvcreate -L 1G -n lv vg_zaphod
 >   Logical volume "lv" created
 > [root at zaphod ~]# lvresize -L 2G vg_zaphod/lv
 >   Extending logical volume lv to 2.00 GiB
 >   Logical volume lv successfully resized
 > [root at zaphod ~]# lvresize -L 1G vg_zaphod/lv
 >   WARNING: Reducing active logical volume to 1.00 GiB
 >   THIS MAY DESTROY YOUR DATA (filesystem etc.)
 > Do you really want to reduce lv? [y/n]: n

Briefly, answered "y" here lvresize does what asked for and cuts 
filesystem into two. Though it says it will destroy data it was still 
reversible operation, resizing incomplete FS later not so, but running 
fsck dealt an ultimate blow to the FS.

 > Now, the important question: Have you done a backup before?

I hope not getting an answer does not mean no.

-- Marian


On 02/10/2013 09:54 PM, Marian Csontos wrote:
> On 02/10/2013 12:23 AM, fakhreddine HABIB wrote:
>> Thank you again Marian.
>>
>> I tried first with the second point to run `fdisk /dev/sda` and i change
>> the `Id` of /dev/sda2 to `8e`, using the Live Cd of Ubuntu.
>> Now i can see the VG group ' vg_regalcauchy, thank you a lot for this
>> point.
>>
>> Now, i have a problem .. i don't know what the reason. I tried after to
>> reduce my volume in ' dev/vg_regalcaucy/lv_home' to have a big space to
>> install Ubuntu, when i reduce the volume, i had a problem with the
>> filesystem size was 26214400 blocks and the physical size of the
>> device is
>> 24962048.
>> When i use the resize2fs it didn't work, i fix the file system size
>> manually to 24962048.
>
> Hello. Oh no! I am afraid this is the most common mistake I have seen:
> people do first shrink the LV and then the FS, while it must be done in
> reverse order. The wrong way just removes part of FS first, so there may
> be uncomplete files. And any attempt to fix the FS makes it worse -
> links to data in the removed part of FS are broken now.
>
> NOTE: There is a `fsadm` command which does handle resizing of both LVs
> and FSs which should be used instead.
>
> Now, the important question: Have you done a backup before?
>
> *Yes*: Very well! Just restore the data from Backup and repeat just
> shrink the FS first and everything should be fine.
>
> *No*: I am afraid there are going to be files lost, depends very much
> how full the filesystem was.
>
> If possible do a backup now - you may need to return to it and retry...
>
> Then you should increase the size of the LV back and then increase the
> FS size back to original value.
>
> Try running fsck now, but be prepared for lot of errors.
>
> You should check files in lost+found and if any valuable data are there:
> fragments of your files,...
>
> -- Marian
>
>> but when i want to mount the ' dev/vg_regalcaucy/lv_home', i have the
>> message :
>>
>> mount: wrong fs type, bad option, bad superblock on
>> /dev/vg_regalcaucy/lv_home,
>> missing codepage or helper program, or other error
>> In some cases useful info is found in syslog - try
>> dmesg | tail or so
>>
>>
>> And when i try to reboot my Centos system i have the message in the
>> snapshot
>>
>> http://cjoint.com/data/0Bkatrr9BNg.htm
>>
>> Can you help me please to find a solution, i use the partition magic Live
>> CD to use the shell, because i can't have an access to the system...
>> and i
>> don't know how can'i install in the system the ' nfs-common ' if it need.
>>
>> Thank you.
>>
>> F. H
>>
>>
>>
>>
>>
>>
>>
>>
>> 2013/2/8 Marian Csontos <mcsontos@redhat.com>
>>
>>> On 02/08/2013 04:38 AM, fakhreddine HABIB wrote:
>>>
>>>> First thank you Marian.
>>>>
>>>
>>> Hello,
>>>
>>>
>>>
>>>> About the method to reuduce the Pv, i think is risked... I don't
>>>> want to
>>>> take any risk of loosing data ...
>>>>
>>>
>>> - pvresize will not resize if there are data in the trailing disk
>>> space to
>>> about to be shrinked
>>>
>>> - pvmove will mirror the data until moved successfully and even on
>>> failure
>>> will start again
>>>
>>> There is a short interval when LVM metadata are updated where system
>>> crash
>>> could result in troubles, but this is no more risk than increasing
>>> logical
>>> volume size...
>>>
>>> If you need creating new partition, you have no other option than
>>> resizing
>>> the PV.
>>>
>>> *Backups, backups, backups!*
>>>
>>> Though I am quite confident LVM user now, I am always doing backups when
>>> shuffling round partitions.
>>>
>>> Perhaps the easiest way if you have a spare USB HDD around is to run a
>>> live CD and `dd` the /dev/sda there (like this `dd if=/dev/sda
>>> of=/path/to/file/on/your/usb/**disk.img bs=1M`) If anything goes wrong,
>>> you can simply switch the if and of params, and everything will be back
>>> where it was before.
>>>
>>> *Virtualization?*
>>>
>>> Actually, there is an option: if your machine is HVM (Virtualization
>>> enabled) you could still install and run Ubuntu in a virtual machine.
>>>
>>> CONS: slower, more memory consuming (2 OS are running at the same time),
>>> not all HW is accessible...
>>>
>>>
>>>
>>>> I tried your idea if i can install ubuntu and Centos in the same
>>>> Physical
>>>> partition, using a logical one .. but i can,t find the way to do that..
>>>> Ubuntu installation interface give the whole /dev/sda2 but i can't see
>>>> the logical volumes (I talk about logical volumes of a LV group)
>>>> (attached
>>>> pics)
>>>>
>>>
>>> Too bad. Looks like the installer does not recognize LVM partition.
>>>
>>> Is it possible the partition used does not have a partition header?
>>>
>>> Run `fdisk /dev/sda` and there you could try `p` to print partitions.
>>> `Id`
>>> should be `8e` and `System` Linux LVM. If that's not so, try `t` and
>>> change
>>> 2-nd partition's type to `8e`.
>>>
>>> That may help ubuntu recognize the LVM partition.
>>>
>>> If not, try asking on Ubuntu forum...
>>>
>>> -- Marian
>>>
>>>
>>>> thank you.
>>>>
>>>>
>>
>


