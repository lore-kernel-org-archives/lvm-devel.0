Received: from mx0a-0066f901.pphosted.com (mx0a-0066f901.pphosted.com [205.220.160.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A21714A4E9
	for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 12:01:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.160.221
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740484896; cv=fail; b=nEZTjzE30TqM/E3z2VoF/CQSs5lUCatG7A1D4MV3Yclmpqfa/Pd5k+ISB4F7pSr/oxO1x+k0JLQ3sF3M63AUEfirGdc+7TQrBdeczFoWVBR/l1AzZlnz0riNgrck+IYFFUje2GSlAbE3pIpPCobf3a58we6npWlgm5LFo3Yag7k=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740484896; c=relaxed/simple;
	bh=kEueJ8+Asolewy2LTTrX9ZctyyAQcmLhr6r3GULhRX8=;
	h=From:To:Subject:Date:Message-ID:Content-Type:MIME-Version; b=Bz1hUQD6ylMn7qEQdT4p1XgzngCYb1VFChmuMBjX5LXv53FFn9Qg25erGvX01ZClUam273D4G9i0duhnwknLsYCqP1kXXv3yCIp45X93qBbQm1GD0QzU9UjQpJ90z+C8zZXfG/G62Yx+FJVY562pTDwUlr5xkwsQ6spZG3wZ0M4=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kyndryl.com; spf=pass smtp.mailfrom=kyndryl.com; dkim=pass (2048-bit key) header.d=kyndryl.com header.i=@kyndryl.com header.b=KjkpFWs7; arc=fail smtp.client-ip=205.220.160.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kyndryl.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kyndryl.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kyndryl.com header.i=@kyndryl.com header.b="KjkpFWs7"
Received: from pps.filterd (m0268692.ppops.net [127.0.0.1])
	by mx0b-0066f901.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 51PBVDW6025686
	for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 12:01:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kyndryl.com; h=
	content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=pp1; bh=kEueJ8+Asolewy2LTTrX9ZctyyAQ
	cmLhr6r3GULhRX8=; b=KjkpFWs7UmVv0/OdDbzrF4tN4UqVjrbYX2FrMjRCI2w3
	mgDKN1lFvFZYdBIacOkVjT5ijnBvavwMtI2+XlKEueAX31t59dyHtuPQbFxle2UG
	t9OZ+BD9gZrvINlPz3e6qt39cUNk868NtFvagil8aR7GJ8dJ65ms2MFyvlMlDMxm
	yART1YwoILkpx7G1BexQYLKzGRITC3fX5/BqtvYXxf79a7xaB08IT5XVMJPcr/IA
	gnNrhHiFbwt4z22Gp+XjUhzjzzinM+JTR3bshGBTkgfVjc2aXp7/VW4c2PqFashK
	i9yAX03Xu4Ze01IbQ/6aSd7ceuHqx94aDA+xOdClFw==
Received: from nam10-dm6-obe.outbound.protection.outlook.com (mail-dm6nam10lp2045.outbound.protection.outlook.com [104.47.58.45])
	by mx0b-0066f901.pphosted.com (PPS) with ESMTPS id 451ct0h2dn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 12:01:33 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=lPq9mlj9mc9fa8bJPtvftY3NPIkLpSJAAOj/pQqhuRqvC/cwQnYnumNnGZi1NocAewIGzX5Ma2hb6RwsQ/JQSVcUeS1CkUyeXqyz7rREj/5q8XezBN7vCKB3/ZRdoijyhZA7Gv3ebjLEUVd4I+6NxURGTOhkm6tymq9LwPJtw/LfupP8PN3Vjuj6MCZn208SiiBZPwe8BaFeL/YjTE+qy3Mqt65vv2GKRam8suec+NnSjn5No/WJ7uGYXdgWZpl8hvaJXyihgZ85i1cB1X4LRroqjMa+Ojg2RAOHp47dzm9SgRQU+86gnDqADyFj9McHF89VYZH5MwNrzzbyBSRpOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=kEueJ8+Asolewy2LTTrX9ZctyyAQcmLhr6r3GULhRX8=;
 b=rLWRMf+hbYMkReQtvE+J0I68vI5PqjOzrHJ+gwlFuBLui97KNRj1frS10kB2U4yw/ykdBO8Q5VU09hKoCgWk7otynwbyetiKq1V/06anhnGlYNOgJw3+HpLgBLXvXZfSW31j3BA8RRqgYK0TZjLqJRD9aN1hPLbZK+9wrSouTY+QkcCcJjo1yOvzTCV+nsq45T4vRIYKvvIbVb3qfIIC6zijalj4n267MfUBkY+zSfJqhWiIGQYEDksKO0VTAI1ZyM74EXtvSQqYULrr2Q92OMksJqb3v80FxUD4KcT07HNiiPtHlGU1Ypc+kN9fdk2gfVvd7RremxOsgLQE74uL+Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kyndryl.com; dmarc=pass action=none header.from=kyndryl.com;
 dkim=pass header.d=kyndryl.com; arc=none
Received: from BYAPR14MB2967.namprd14.prod.outlook.com (2603:10b6:a03:152::20)
 by PH7PR14MB5668.namprd14.prod.outlook.com (2603:10b6:510:213::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8466.19; Tue, 25 Feb
 2025 12:01:31 +0000
Received: from BYAPR14MB2967.namprd14.prod.outlook.com
 ([fe80::2119:f981:7d9a:5244]) by BYAPR14MB2967.namprd14.prod.outlook.com
 ([fe80::2119:f981:7d9a:5244%5]) with mapi id 15.20.8466.020; Tue, 25 Feb 2025
 12:01:30 +0000
From: SCOTT FIELDS <Scott.Fields@kyndryl.com>
To: "lvm-devel@lists.linux.dev" <lvm-devel@lists.linux.dev>
Subject: Migration of disks within a clustered LVM2 volume group
Thread-Topic: Migration of disks within a clustered LVM2 volume group
Thread-Index: AQHbh3yLuWHLjloP50GWu0XX8T2Dsw==
Date: Tue, 25 Feb 2025 12:01:30 +0000
Message-ID:
 <BYAPR14MB2967BDF2FF9A5B29E90D09A68AC32@BYAPR14MB2967.namprd14.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: BYAPR14MB2967:EE_|PH7PR14MB5668:EE_
x-ms-office365-filtering-correlation-id: bc073acb-650c-4610-c77f-08dd55942415
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;ARA:13230040|366016|376014|1800799024|38070700018;
x-microsoft-antispam-message-info:
 =?Windows-1252?Q?kdCC8R3sRWUN7HEDZTqs3bn9Bn0ja1v2KwGFuraz3EeuZZ7SiKdoZGwg?=
 =?Windows-1252?Q?FMrx7jh/UShB6D5WDNblASXOyZF70Wh33DGGi3vjKlgUg8rpUjKMrY2i?=
 =?Windows-1252?Q?E1O+dpBPNinQPvdNwmXLTvis4aARv41H44UtyTErAlnJ5G3xXXHn/jyh?=
 =?Windows-1252?Q?H+fAWYEWrkqlwB+b0Oq695ho9XrKsCBy98vVPvLEj/IliXRQJfZOntsK?=
 =?Windows-1252?Q?SdER7o8xg5SBXkDv+SKlD+euSqdz7lGXMq8bbjBZfpxrs1wtgDXbqpww?=
 =?Windows-1252?Q?iUa+c7iC1BnVjDFdVOI5zn5Achc0htcSP+/nru/DXVS0PRLvS2WG6w68?=
 =?Windows-1252?Q?Gv3014POJPYZsUez/200ghp65+F0CPF83K4UUy/W1QAwxvfDgXBLJuvl?=
 =?Windows-1252?Q?U6EvJ9N5A9AW/FNJiaFxxhypETwtqhNT2cEia2GfmG81kNrApaBjZUok?=
 =?Windows-1252?Q?cNHP2f7/Gn5pnrl4UTskMsvmffiHDJCTf7f959tMvpu7aNjauVYK4TH0?=
 =?Windows-1252?Q?pQsoWqm5Idks0LRW2vkwYKLKSP8l+dP4HyC62/1eJG9eU+BlxCkPwp80?=
 =?Windows-1252?Q?GAkIardZa/eAsJ2iPLjwa7AXOgNIE7N6BRJVByBDywLko3KTuj+ocYxz?=
 =?Windows-1252?Q?5y7Cj+ZLVzzPfUnxTypEsNK1PcrwDktm/b7FW0SKI/vnnPRon7CL2URv?=
 =?Windows-1252?Q?JQE0tOiDB2OGi1qK3yn0nnruw/R5O40fK+qrB14ENjWH9R6COAoaYgAj?=
 =?Windows-1252?Q?C8uJIqHx0Ovv8Sdzu1UvO9/P/u6kDbqz7WUbqDsHIhiLYHxwGrI93hiG?=
 =?Windows-1252?Q?0XVV4xeZr1FxnwSpTD8PsgK27q7O2E/2mTZKZ8RGk35Jip0ZmsVKcgig?=
 =?Windows-1252?Q?q746UR7WNlZbz/G+xU4Y4LKUFIvNfkEbYqHzn/rKnS9me7FNjS/DjYrA?=
 =?Windows-1252?Q?1hMGJWPe54QyJbH3hkLfjWLvPWTYpF5ge9r4sL6BVwkXN1aj7eOb18bo?=
 =?Windows-1252?Q?SiFIMJdGKOMnOZtbRV8RZqXvV47tI2zWksQ7KVKimIdIDy2y3J/Ywx59?=
 =?Windows-1252?Q?YnP3N0kjbUIqbIs7uj9taAO+CkUld/cUTdeoBKN1WPyuxtrfVWd+XNul?=
 =?Windows-1252?Q?wmodszrfP/6I2NK5+CEdvxTxZa2W/w/naxRrLN0miKsWbt88hvOqEEN7?=
 =?Windows-1252?Q?K8wggTgGq23a32OFlGY1azLw4IWLzbqmeSwuhDE6ktNwPO6kKaIbmNJV?=
 =?Windows-1252?Q?EjWN16+E43NvzyOSmZvaNFHCHE0Go4rytzyH6NqNm+55707vfzd/voeP?=
 =?Windows-1252?Q?AB0LUGJDqOONBXF3MxNIKZaXMiWLA5iZG/R0fxMh1DrghEejc3WMIRmP?=
 =?Windows-1252?Q?zUiXNPMYQdynd4W18/H0bdG66Ge3Bo6/pvjZpgZiHqGS2/z9Xl0F14Np?=
 =?Windows-1252?Q?s5g1iDzk7CLDZDu+IIiKzOxycED+vZqhB2AvU07vtYvQ8kJlaGgo9MQJ?=
 =?Windows-1252?Q?V4EVI/A1uINSjRR6i93A9vlT/geEt20PsS/90rYjeghYLNgKd9CARBmL?=
 =?Windows-1252?Q?fw4LJx/UmsB4HEsE?=
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:BYAPR14MB2967.namprd14.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(376014)(1800799024)(38070700018);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?Windows-1252?Q?S593oI5KV8NnpiGpec7ITymc+byW7dJkNMIJdQf7fbW820QLXN5tWxk5?=
 =?Windows-1252?Q?fCXUv0OThIZ031vLdeMFRPHI9XAsy3LwmDYYY9ODArYSEkT+iI+esyFr?=
 =?Windows-1252?Q?v/vTS6EgLqWRmx2+E/Pwq34u7BXrM1CzHLoInj1oJs1JAI1Db9dK+UTb?=
 =?Windows-1252?Q?U0WPBYYhNVHnKaDDbTRWtDGIkk90vbwkA+Dyzlya96qt94P7Boigqns+?=
 =?Windows-1252?Q?RL7eUzzhwP4mFClEr9trQXmxp25PaUGdV2iaSLvsDjLSpNPg0D4eoZiY?=
 =?Windows-1252?Q?LmOaw2a5FSqcd2P0y9GyrBjlgmirQocxR4fiF0Z2U8DscevxNOgS3LIl?=
 =?Windows-1252?Q?sWSMsPrcDQHVyyfS440kqF2zCQymYhzbnl2OAP3B4TM4cUIcfbpWBPHx?=
 =?Windows-1252?Q?jiCNCKGLRzfGuhn4Vfkh83Uu5EuNBB+6CtCLqg0xeX87xefoi/19xtK6?=
 =?Windows-1252?Q?zfyHTebUPlfQEi+RXp0nvbEBw67dPzJOnG7b3BxAXAhdtcG5kpJwmGFn?=
 =?Windows-1252?Q?yjDO7XYGmX3ZxbDPSekfUxKYhjO8JiGPcBJZg7dVQuroOSWy3yPc2uPd?=
 =?Windows-1252?Q?hXUS5oxXadGFI1Fppt7pfdf6Cz0R83FCeHFbqXKWco3kpBurgonYoC4l?=
 =?Windows-1252?Q?/ERFQtF7lH5Hnj9NZh6gPJUMP25FwV/2XfPZ0C2SZukGHAW0LXaSftCn?=
 =?Windows-1252?Q?cmNTa5YGSTGd0dG8mgUwMuKQzav9nyjuPDzY5eh2Tyy74h5QVZirhoVP?=
 =?Windows-1252?Q?0BJSlxcCnW783mfVHn23f9ybliVQrqiUdv2Oq4BlpDqIgi46hqzLiaL0?=
 =?Windows-1252?Q?kFe/a1F7JZhIvSm1dJxUrqGUAvYj003G11hs+OSQZMq0r9KaWNW9Aqk4?=
 =?Windows-1252?Q?6CQxPBdNp9RoSVe2rwAbOua6nzZM4mTcmoMwUAUQRXxHgiQIYPqE0fpR?=
 =?Windows-1252?Q?GDUv0gJT/orgMSZ5yy9+yxQy/V053l4fsOSlIt+7mqiS2P0yTbt/4rwk?=
 =?Windows-1252?Q?M5zz5XLQoRzwOljGdlUZI9tFTW4ZKk2dKnI7XaMTkDZkAyG/w1ASr4nc?=
 =?Windows-1252?Q?U1VZCGtrwIhb7XjrXI9bK5m60zjym7KodlDQZqOdNVZOj9N+vDcchWk2?=
 =?Windows-1252?Q?p9UJkiwzvUlc5J4acycKhk+LSqL0fyZw/wr651zNtF3dOSZgw3T8SrB+?=
 =?Windows-1252?Q?pAaP+O3p73Z7Dov3kpckZJCv6LP3P+HZIqOnKpopvwd6jq8KhZBcZ2pg?=
 =?Windows-1252?Q?AkYqmCgxPWAag0DVntWu2chGR7Ol2b+OGgRiGpN2++4+B1xdGiT9Qygv?=
 =?Windows-1252?Q?V1ZFdwOxwYQdBUqdqHqGPxS+U615823Kmc0j5MP24mQlNn8zuJV2CPl2?=
 =?Windows-1252?Q?58vfQaFd1gIgzxob9h/cv7bLlyQat3Q47c1i+OQqIXjnDL/aeQRn3q7t?=
 =?Windows-1252?Q?jV7bBuUVxiXNHbU4t+yD8t5YdIyhioBiVnMte3Q8tuKVlnqDgycMLD/J?=
 =?Windows-1252?Q?X9iU6UBtaROPlahyvkd69T3HD5im0MddBWUShTQCBJUaYWuBuiCQ39Ga?=
 =?Windows-1252?Q?vbPR2dOwcTcq/eKuKimhD5nnE2yS2KHRJZ8TUdwvzWZyLyECZjud28C/?=
 =?Windows-1252?Q?Ph4Ye9vv4/WK8FbRF2PtDx8yGjy45iXcyA+QPFSIcFDN7LtNEFk6vTFV?=
 =?Windows-1252?Q?zxAhlQH6tOcaAihEkJz6daJHFB6Df5qz?=
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-OriginatorOrg: kyndryl.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: BYAPR14MB2967.namprd14.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bc073acb-650c-4610-c77f-08dd55942415
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2025 12:01:30.4842
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: f260df36-bc43-424c-8f44-c85226657b01
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: JziTRUf2qXmOVupL72rqRptm3Q/Fyf4gUj6YZ+OO6aBLhp6vJlrYQOp+x+tvlmmmr+wkFJE7hdOFE+TBx1mT7mrR5dAWINO8a5XuD8oGa90=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH7PR14MB5668
X-Proofpoint-ORIG-GUID: Krx010rTVYI2oFvgX9cC5XYZs9J_kny3
X-Proofpoint-GUID: Krx010rTVYI2oFvgX9cC5XYZs9J_kny3
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1057,Hydra:6.0.680,FMLib:17.12.68.34
 definitions=2025-02-25_04,2025-02-25_03,2024-11-22_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 adultscore=0 impostorscore=0 mlxscore=0 lowpriorityscore=0 bulkscore=0
 suspectscore=0 spamscore=0 mlxlogscore=698 phishscore=0 malwarescore=0
 clxscore=1015 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.19.0-2502100000 definitions=main-2502250083

It has been stated that mirroring is deprecated in clustered LVM2 configura=
tions and currently unsupported.=0A=
=0A=
To migrate a physical volume to a new physical volume requires the volume g=
roup to be brought into a non-clustered state to perform the migration. Aft=
erwards, it can be brought back into a clustered state, post migration.=0A=
=0A=
Is there any alternative, since doing so is disruptive twice, and counter t=
o it being a clustered system.=0A=
=0A=
Scott Fields=0A=
Kyndryl=0A=
Senior Lead SRE =96 BNSF=0A=
=0A=
=A0=
