//
//  DatabaseDebugHelper.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/19/25.
//

import Foundation
import FirebaseFirestore

class DatabaseDebugHelper {
    private let db = Firestore.firestore()
    
    func debugCollections() async {
        print("🔍 Debugging Firestore Collections...")
        
        // Check specific collections we need
        await checkCollection("organization_info")
        await checkCollection("support_mission")
        await checkCollection("external_links")
    }
    
    private func checkCollection(_ collectionName: String) async {
        print("\n🔍 Checking collection: \(collectionName)")
        
        do {
            let snapshot = try await db.collection(collectionName).getDocuments()
            print("📄 Documents in \(collectionName): \(snapshot.documents.count)")
            
            for document in snapshot.documents {
                print("  📝 Document ID: \(document.documentID)")
                print("     Fields: \(document.data().keys.sorted().joined(separator: ", "))")
                
                // Special handling for specific documents
                if collectionName == "organization_info" && document.documentID == "main" {
                    let data = document.data()
                    print("     📞 contactPhone: \(data["contactPhone"] ?? "MISSING")")
                    print("     📧 contactEmail: \(data["contactEmail"] ?? "MISSING")")
                }
                
                if collectionName == "support_mission" && document.documentID == "main" {
                    let data = document.data()
                    print("     📝 headerTitle: \(data["headerTitle"] ?? "MISSING")")
                    print("     📝 mission: \(data["mission"] ?? "MISSING")")
                    print("     📊 impactNumbers: \(data["impactNumbers"] ?? "MISSING")")
                }
            }
            
        } catch {
            print("❌ Error checking collection \(collectionName): \(error)")
        }
    }
    
    func debugSpecificDocument(collection: String, document: String) async {
        print("\n🔍 Debugging specific document: \(collection)/\(document)")
        
        do {
            let doc = try await db.collection(collection).document(document).getDocument()
            
            if doc.exists {
                print("✅ Document exists")
                print("📄 All fields:")
                let data = doc.data() ?? [:]
                for (key, value) in data.sorted(by: { $0.key < $1.key }) {
                    print("   \(key): \(value)")
                }
            } else {
                print("❌ Document does not exist!")
            }
            
        } catch {
            print("❌ Error fetching document: \(error)")
        }
    }
}
