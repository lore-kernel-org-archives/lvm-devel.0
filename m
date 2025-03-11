Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C19E3FD1
	for <lvm-devel@lists.linux.dev>; Tue, 11 Mar 2025 02:03:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741658623; cv=none; b=YGhOZyUcy/lCEZCoOxSk2/NxjOm3YKzdh8sJEBy4CDz4+KVMzC2F/PXjJ7iRNHbN4knVP3/a9zG89Ec/fngpjGtfjzL1E/cdp4+SfpOa9MNgE8929mrX8HFKC+Y0bKaKLAXgNyCkf8Mv7fWSilmgnOos4duPIs9MEQe+baSa9JU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741658623; c=relaxed/simple;
	bh=L5QgwkfFVwysgFcVv8SrLpRLcUFtbRSfcoMQCykkN0I=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=NEUALUxa22gzV2YYoYRIJ8G2AcEnfFf8EpyJEjleKSgObWh4Qdim+qw46eVmRyg+E/QAHpLzxcCRc/Rl/lf39BbZDoT5Wg+bC5BTZC7tiJp/ZP/YfekzaDXRUup6tcK88XlkJwOIIOWdq2cjoL59N86YvM0eVZyrmMgbY5o4YQQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=dXxkbtXr; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="dXxkbtXr"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-43ce4e47a85so3139095e9.0
        for <lvm-devel@lists.linux.dev>; Mon, 10 Mar 2025 19:03:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1741658619; x=1742263419; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:content-language:from
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=rsymZb5xw24np9u2gSHDgS1ZRCWkhg2X4+SnvgCF89E=;
        b=dXxkbtXrE0PoocP2a6XBj9wXO6WY6BcrY/hNdOT3xz9JIUOghbF0Ym399lNYhza6W/
         MOJs8Vlr9Tztx6uDX8Y0KxG5kDB0X8b/d++Sv2noDruRDgf/8JwRnyS86N0dNtk4HSGq
         lS6FnRXaXko/OA1IXhYW6IfS4NGFc0fXR/YfGdYwNLGYAz8wo7wcZF+fEfODctBAFTkv
         iYER9INTAl4HCMr1aLnJ98AM/1UiJ+0SfCPVgB8Et0H/tvpQ/+teSRsdWYiqNjsXKCya
         L6w/73qOMEXF94lutaJCDeID/fWh/TJTtATD8yaoeuqQtuctjH36WhR72j8mVT+movBJ
         bp9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1741658619; x=1742263419;
        h=content-transfer-encoding:in-reply-to:content-language:from
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=rsymZb5xw24np9u2gSHDgS1ZRCWkhg2X4+SnvgCF89E=;
        b=eUz+Dcq7hWHtAyUmp3HK+RsHV89Arz+TNi8z3Zjy0UjKpczef5wsybG8/Zm40bryw6
         APuGP1nas23zIg6wbqTcliGMUCKjj9abetbLjnMpRFEsD+0nWTj7qSU5AJF3FHxpBL7U
         VBwhWpSTOyokwjCD51VfOXsS/HbkN5kA79LdpuFJx853GY6WbpyeQDWrhUb+kfRd7XsU
         xpId5+wlUT5+sd58quYS/9+poiotpRRS3Hmt/Yl9n+O+cgfptNVwMfeFcE700QWGest/
         wFbZ5wweCaA/HiB/Jc5w7YZ1nVykzPVrF/PNffAHAkGNh3THu/pzyJz1EA3Rlastp9IA
         csuA==
X-Gm-Message-State: AOJu0YyOq8hEU53RgPHz2haPfmOzeLZNdm2v5aCJe+ApOFF2PCFdfRX0
	KoTWMQtAo+Y3NU9rrXWGPFhHE77g+3kdJ5CKiwHt5gGeyKQHcPVMC+W4j0LHNiM=
X-Gm-Gg: ASbGncvpFK+GseQeulJ20GALJSNkT2Od0vfj13RJONivHqMWqKHu2GH5kU5FpDGEzZk
	hQ6nbiQvMeX6J8PVO4FDEhukTGrgSUUz4aX3LiY92c61iWMJ5GTaYencMlsxG+7E8/Gi/ImCVUL
	8diHoz0QY4kXbQ/q+GEEL18ZDNkqyBrnLK+FJ2nQTiiujTYfjRI+LjPepZi40FsNai2HkV/WhuC
	oqTUHmHSgcPaELu5loUcZh3rJET8pGBOMqCCOWsQDQUMlF4CM2hQaHla7zQPn72s0nuyT4CDGFl
	1Fj5lESc6Cvn7BmcgTI8sdvDheyH2BIqqexNmFxYGx84oT/Xr2o=
X-Google-Smtp-Source: AGHT+IHVYlnXfdXUA2oy78dRULFi95kDjy99MNiWssE4lSaCiutds9+d91eiWNPAtAh2ocbroVXxfQ==
X-Received: by 2002:a05:600c:4f52:b0:43b:bbb9:e25f with SMTP id 5b1f17b1804b1-43d01c266a1mr10704725e9.6.1741658619500;
        Mon, 10 Mar 2025 19:03:39 -0700 (PDT)
Received: from [10.202.112.30] ([202.127.77.110])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-22410a9194csm85814335ad.172.2025.03.10.19.03.37
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 10 Mar 2025 19:03:38 -0700 (PDT)
Message-ID: <092da404-36a5-4a64-96f8-df10b8f09f5e@suse.com>
Date: Tue, 11 Mar 2025 10:03:36 +0800
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Request for comments about support btrfs in lvresize
To: Glass Su <glass.su@suse.com>, David Teigland <teigland@redhat.com>
Cc: lvm-devel@lists.linux.dev, zkabelac@redhat.com
References: <D418C150-C1F3-4067-9B72-65C4542DF19F@suse.com>
 <Z88QTwcyqqn-faz_@redhat.com> <C6FA4A06-7C7B-415E-A46E-302E1CAE9E36@suse.com>
From: Heming Zhao <heming.zhao@suse.com>
Content-Language: en-US
In-Reply-To: <C6FA4A06-7C7B-415E-A46E-302E1CAE9E36@suse.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 3/11/25 09:47, Glass Su wrote:
> 
> 
>> On Mar 11, 2025, at 00:24, David Teigland <teigland@redhat.com> wrote:
>>
>> On Mon, Mar 10, 2025 at 04:35:54PM +0800, Glass Su wrote:
>>> Hi
>>> I am drafting patches for btrfs support in lvresize command. All things went smoothly until I realized
>>> multi-devices btrfs handling is a little complicated.
>>
>> btrfs using multiple devices sounds like an alternative to putting btrfs
>> on lvm, so is this actually done?
> 
> Yeah. Btrfs don’t care about the backing device is lv or not. It just treats devices as how ext* and xfs do.
> For those people don’t trust btrfs raid stability especially raid56, the use case indeed exits.

I feel that few users use btrfs on lvm2 with multiple LVs. because I have
never received any issue related to btrfs on lvm2. And from what I remember,
there are ​not too many users using LVM2 RAID mode either. People ​tend to
prefer using ​mdadm to manage RAID disks (or using hardware raid card).

Anyway, it is ​possible to set up btrfs on LVM2 with multiple LVs, so we
should support this scenario.

- Heming

>>
>>> For one device btrfs, fslastblock * fsblocksize/FSSIZE is the correct value like ext* and xfs
>>> But for multi-devices btrfs, the two values are whole fs size. The used size of device can be
>>> known by btrfs-progs or superblock read and parse.
>>
>> These values are used to calculate fs_last_byte, and that is used:
>>
>> - by lvextend as a sanity check after the fs resize is done.  So, it could
>>   be made optional for lvextend.
>>
>> - by lvreduce to check if the fs has already been sufficiently shrunk, so
>>   the fs shrink command can be skipped.  Perhaps for btrfs, always require
>>   the fs shrink command to be run, and always make fs_last_byte large enough
>>   to do that.
> 
> Right. I’ve considered the way making fs_last_byte zero/large enough as `btrfs filesystem resize ` can
> handle the newsize rightly. For me, it’s more like a quirk. If it’s acceptable to you I can provide a patchset to implement
> the logic, and a testcase, of course.
> 
> —
> Su
>>
>> Dave
>>
> 

