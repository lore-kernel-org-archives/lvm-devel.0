From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 21:15:47 +0100
Subject: [PATCH 02/24] Replace PV_MIN_SIZE with function pv_min_size()
In-Reply-To: <4D45C3AF.7010702@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>	<10a41c93f0c3f21e0ed40a74184001ca6b51bd19.1296391340.git.zkabelac@redhat.com>
	<4D45C3AF.7010702@redhat.com>
Message-ID: <4D45C6F3.5000000@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.1.2011 21:01, Milan Broz napsal(a):
> 
> On 01/30/2011 01:57 PM, Zdenek Kabelac wrote:
>> Add configurable option for defining minimal size of PV.
>> pv_min_size() is added to lvm-globals and it's being
>> initialized through _process_config.
>>
>> Macro PV_MIN_SIZE is unused and removed.
>>
>> New define DEFAULT_PV_MIN_SIZE_KB is added to lvm-global
>> and unlike PV_MIN_SIZE it uses Kilobytes units.
>>
>> Should help users with various slow devices attached to the system,
>> which cannot be easily filtered out (like Fdd on /dev/sdX):
>> https://bugzilla.redhat.com/show_bug.cgi?id=644578
> 
> I think you are mixing two distinct things here
> 
> - minimum PV size
> - minimum device size which is considered for lvm metadata scan
> 
> I think that minimum PV size should remain fixed in code.
> The second is runtime variable, you can adjust it per user needs.
> 
>> +
>> +    # Minimal size (in KB) of PV partion which will be consider to be able
>> +    # to hold PV. It allows to automatically skip too small partitions
>> +    # like FDD devices from scan. Any value smaller then 512 is ignored.
>> +    pv_min_size = 512
> 
> I thought we meant:
> Minimal size of device, which will be scanned for LVM metadata.
> 
> IOW it should be filter, not limitation for PV creation.
> 
> (But maybe I just misunderstood what Alasdair wants here...)
> 

Note: there is still hard coded 512KB value in the source code.

But what would be the point of creation of PV with smaller size then
configured pv_min_size?

i.e. if you configure pv_min_size = 10MB - you cannot create  smaller PV - as
it would be invisible in your system - IMHO it could eventually lead to bigger
confusion - you create small PV, which will be invisible for lvm tools...

If you want to create and see smaller PV - lvm.conf needs to be set to smaller
value.

Zdenek


