//
//  ServerPackModel.swift
//  Feather
//
//  Created by samara on 5.05.2025.
//

struct ServerPackModel: Decodable {
	var cert: String
	var ca: String
	var key: String
	var info: ServerPackInfo
	var version: PackVersion?
	var domain: String?
	
	private enum CodingKeys: String, CodingKey {
		case cert, ca, key1, key2, info, version, domain
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		cert = try container.decode(String.self, forKey: .cert)
		ca = try container.decode(String.self, forKey: .ca)
		let key1 = try container.decode(String.self, forKey: .key1)
		let key2 = try container.decode(String.self, forKey: .key2)
		key = key1 + key2
		info = try container.decode(ServerPackInfo.self, forKey: .info)
		version = try? container.decodeIfPresent(PackVersion.self, forKey: .version)
		domain = try? container.decodeIfPresent(String.self, forKey: .domain)
	}
	
	struct PackVersion: Decodable {
		var num: String?
		var message: String?
	}
	
	struct ServerPackInfo: Decodable {
		var issuer: Domains?
		var domains: Domains?
		var notAfter: String?
		var notBefore: String?
	}
	
	struct Domains: Decodable {
		var commonName: String?
		
		private enum CodingKeys: String, CodingKey {
			case commonName = "commonName"
		}
	}
}
