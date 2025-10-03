#!/usr/bin/awk

function inInterfaces(host) {
	return(interfaces ~ "(^| )" host "($| )")
}

function total(i) {
	return(bw[i "/in"] + bw[i "/out"])
}

BEGIN {
	if (ipv6) {
		iptNF	= 8
		iptKey	= "ip6tables"
	} else {
		iptNF	= 9
		iptKey	= "iptables"
	}
}

/^#/ { # get DB filename
	FS	= ","
	dbFile	= FILENAME
	next
}

# data from database; first file
ARGIND==1 {
	lb=$1

	if (lb !~ "^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$" && lb != "NFT") next

	if (!(lb in mac)) {
		mac[lb]		= $1
		ip[lb]		= $2
		inter[lb]	= $3
		speed[lb "/in"]	= 0
		speed[lb "/out"]= 0
		bw[lb "/in"]	= $6
		bw[lb "/out"]	= $7
		firstDate[lb]	= $9
		lastDate[lb]	= $10
		ignore[lb]	= 1
	} else {
		if ($9 < firstDate[lb])
			firstDate[lb]	= $9
		if ($10 > lastDate[lb]) {
			ip[lb]		= $2
			inter[lb]	= $3
			lastDate[lb]	= $10
		}
		bw[lb "/in"]	+= $6
		bw[lb "/out"]	+= $7
		ignore[lb]	= 0
	}
	next
}

FNR==1 {
	FS=" "
	if(ARGIND == 2) next
}

# arp: ip hw flags hw_addr mask device
ARGIND==2 {
	if (ipv6) {
		statFlag= ($4 != "FAILED" && $4 != "INCOMPLETE")
		macAddr	= $5
		hwIF	= $3
	} else {
		statFlag= ($3 != "0x0")
		macAddr	= $4
		hwIF	= $6
	}

	lb=$1
	if (hwIF != wanIF && statFlag && macAddr ~ "^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$") {
		hosts[lb]		= 1
		arp_mac[lb]		= macAddr
		arp_ip[lb]		= $1
		arp_inter[lb]		= hwIF
		arp_bw[lb "/in"]	= 0
		arp_bw[lb "/out"]	= 0
		arp_firstDate[lb]	= systime()
		arp_lastDate[lb]	= arp_firstDate[lb]
		arp_ignore[lb]		= 1
	}
	next
}

# NFTables stats parsing
ARGIND==3 {
	# parse lines like:
	# iifname "eth0" counter packets 123 bytes 456 comment "eth0-INPUT"
	if ($0 ~ /iifname/) {
		match($0, /iifname \"([^\"]+)\" counter packets ([0-9]+) bytes ([0-9]+) comment \"([^\"]+)\"/, arr)
		if (arr[1] != "") {
			iface = arr[1]
			pkts = arr[2]
			bytes = arr[3]
			comment = arr[4]
			if (comment ~ /-INPUT$/) {
				n = iface "/in"
			} else if (comment ~ /-OUTPUT$/) {
				n = iface "/out"
			} else if (comment ~ /-FORWARD$/) {
				n = iface "/out"
			} else {
				next
			}
			lb = "NFT"
			if (!(lb in mac)) {
				mac[lb] = lb
				ip[lb]  = lb
				inter[lb] = iface
				bw[lb "/in"]  = 0
				bw[lb "/out"] = 0
				firstDate[lb] = systime()
				lastDate[lb]  = systime()
				ignore[lb]    = 0
			}
			if (n == iface "/in") {
				bw[lb "/in"] += bytes
			} else {
				bw[lb "/out"] += bytes
			}
			lastDate[lb] = systime()
			ignore[lb] = 0
		}
	}
}

END {
	if (mode == "noUpdate") exit

	for (i in arp_ip) {
		lb = arp_mac[i]
		if (!arp_ignore[i] || !(lb in mac)) {
			ignore[lb]	= 0

			if (lb in mac) {
				bw[lb "/in"]	+= arp_bw[i "/in"]
				bw[lb "/out"]	+= arp_bw[i "/out"]
				lastDate[lb]	= arp_lastDate[i]
			} else {
				bw[lb "/in"]	= arp_bw[i "/in"]
				bw[lb "/out"]	= arp_bw[i "/out"]
				firstDate[lb]	= arp_firstDate[i]
				lastDate[lb]	= arp_lastDate[i]
			}
			mac[lb]		= arp_mac[i]
			ip[lb]		= arp_ip[i]
			inter[lb]	= arp_inter[i]

			if (interval != 0) {
				speed[lb "/in"]	= int(arp_bw[i "/in"] / interval)
				speed[lb "/out"]= int(arp_bw[i "/out"] / interval)
			}
		}
	}

	close(dbFile)
	for (i in mac) {
		if (!ignore[i]) {
			print "#mac,ip,iface,speed_in,speed_out,in,out,total,first_date,last_date" > dbFile
			OFS=","
			for (i in mac)
				print mac[i], ip[i], inter[i], speed[i "/in"], speed[i "/out"], bw[i "/in"], bw[i "/out"], total(i), firstDate[i], lastDate[i] > dbFile
			close(dbFile)
			break
		}
	}
}
