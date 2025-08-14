//
//  LocalRepository.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation

protocol DataRepository {
    func loadPrograms() -> [ProgramInfo]
    func loadTeams() -> [Team]
    func loadTeamMembers() -> [TeamMember]
    func loadCoreWork() -> [CoreWork]
    func loadImpactStats() -> [ImpactStat]
    func loadOrganizationInfo() -> OrganizationInfo?
    func loadArticles() -> [Article]
    func loadExternalLinks() -> [ExternalLink]
    func loadSupportMissionContent() -> SupportMissionContent?
}

class LocalRepository: DataRepository {
    static let shared = LocalRepository()
    private init() {}

    // MARK: - Public API
    func loadPrograms() -> [ProgramInfo] {
        decode([ProgramInfo].self, from: "programs") ?? Self.programsFallback
    }
    
    func loadTeams() -> [Team] {
        decode([Team].self, from: "teams") ?? Self.teamsFallback
    }

    func loadTeamMembers() -> [TeamMember] {
        // First try wrapper { "team_members": [...] }
        struct Wrapper: Decodable { let team_members: [TeamMember] }
        if let wrapped: Wrapper = decode(Wrapper.self, from: "teamMembers") {
            return wrapped.team_members
        }
        // Fallback to plain array for backward compatibility
        return decode([TeamMember].self, from: "teamMembers") ?? Self.teamMembersFallback
    }
    
    func loadCoreWork() -> [CoreWork] {
        decode([CoreWork].self, from: "home_coreWork") ?? Self.coreWorkFallback
    }
    
    func loadImpactStats() -> [ImpactStat] {
        decode([ImpactStat].self, from: "home_impactStats") ?? Self.impactStatsFallback
    }
    
    func loadOrganizationInfo() -> OrganizationInfo? {
        decode(OrganizationInfo.self, from: "home_organizationInfo") ?? Self.organizationInfoFallback
    }
    
    func loadArticles() -> [Article] {
    // Prefer bundled Fixtures/medium_articles.json; otherwise fallback to root medium_articles.json
        if let fixtures: [Article] = decode([Article].self, from: "medium_articles") {
            return fixtures
        }
        if let rootURL = Bundle.main.url(forResource: "medium_articles", withExtension: "json") {
            do { return try Self.decodeURL([Article].self, url: rootURL) } catch { /* fallthrough */ }
        }
    return []
    }
    
    func loadExternalLinks() -> [ExternalLink] {
        decode([ExternalLink].self, from: "external_links") ?? Self.externalLinksFallback
    }

    func loadSupportMissionContent() -> SupportMissionContent? {
        // Renamed to singleton style filename support_mission.json
        decode(SupportMissionContent.self, from: "support_mission")
    }

    // MARK: - Decoding helpers
    private func decode<T: Decodable>(_ type: T.Type, from resource: String) -> T? {
        // First, look under Fixtures folder in bundle
        if let url = Bundle.main.url(forResource: resource, withExtension: "json", subdirectory: "Fixtures") {
            do { return try Self.decodeURL(type, url: url) } catch { /* try alternative below */ }
        }
        // Then, try resource at bundle root
        if let url = Bundle.main.url(forResource: resource, withExtension: "json") {
            do { return try Self.decodeURL(type, url: url) } catch { return nil }
        }
        return nil
    }
    
    private static func decodeURL<T: Decodable>(_ type: T.Type, url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Fallback data (mirrors fixtures) to ensure app runs without bundled JSON
extension LocalRepository {
    static let externalLinksFallback: [ExternalLink] = [
        ExternalLink(id: "link.donation", name: "donation", address: "https://www.zeffy.com/en-US/fundraising/chieac-social-impact-project")
    ]
    static let teamsFallback: [Team] = [
        Team(id: "team.core_team", name: "Core Team", code: .coreTeam, description: "Meet the exceptionally dedicated team of educators, advocates, and community leaders who, with unique skills, a shared drive for equity, and deep cariño, empower Chicago’s underrepresented students and families"),
        Team(id: "team.advisory_board", name: "Advisory Board", code: .advisoryBoard, description: "The ChiEAC Advisory Board reflects our communities. Advisors guide donation allocation, programming, needs assessments, and events. We meet three times a year—over a meal—to improve education outcomes for Chicago students.")
    ]

    static let coreWorkFallback: [CoreWork] = [
        CoreWork(id: "core_work.building_coalitions", title: "Building Coalitions", description: "We build coalitions with community partners, advocacy groups, and stakeholders to advance our shared vision for equitable education.", icon: "person.3.fill"),
        CoreWork(id: "core_work.advocacy", title: "Advocacy", description: "We advocate for policies that address root causes of educational inequity and create a more just and equitable school system.", icon: "scale.3d"),
        CoreWork(id: "core_work.storytelling", title: "Storytelling", description: "We use the power of storytelling to elevate the voices of students, families, and educators most impacted by educational inequities.", icon: "book.fill")
    ]
    
    static let impactStatsFallback: [ImpactStat] = [
        ImpactStat(id: "impact.students_served", number: "1,600+", label: "Students Served", subtitle: "since 2020", icon: "graduationcap.fill"),
        ImpactStat(id: "impact.resources", number: "$20K+", label: "Resources", subtitle: "distributed", icon: "dollarsign.circle.fill"),
        ImpactStat(id: "impact.internships", number: "85", label: "Internships", subtitle: "created", icon: "briefcase.fill"),
        ImpactStat(id: "impact.families_helped", number: "500+", label: "Families Helped", subtitle: "supported", icon: "house.fill")
    ]
    
    static let organizationInfoFallback = OrganizationInfo(
        id: "main",
        mission: "We believe in a world where every student in Chicago has the opportunity to thrive.",
        description: "ChiEAC works to ensure every student in Chicago has the opportunity to thrive through advocacy, storytelling, and building community coalitions.",
    tagline: "Serving Chicago students and families con cariño",
    contactEmail: "info@chieac.org"
    )
    
    static let programsFallback: [ProgramInfo] = [
        ProgramInfo(
            id: "program.elevate",
            title: "ELEVATE",
            subtitle: "Professional Development",
            description: "Custom professional development opportunities tailored to the unique needs and aspirations of rising scholars. Built on principles of empowerment, mentorship, and growth.",
            benefits: [
                "85 custom internships created since 2020",
                "90%+ participants gain career-relevant skills",
                "70% secure employment within 6 months",
                "300+ hours of mentorship provided",
                "25 professional development workshops hosted"
            ],
            impact: [
                "Rising scholars connected with opportunities in education, social work, STEM, and nonprofit management",
                "Participants prepared to become leaders and innovators in their chosen fields",
                "Strong professional networks built through mentorship relationships"
            ],
            icon: "star.fill",
            contactEmail: "elevate@chieac.org"
        ),
        ProgramInfo(
            id: "program.data_science_alliance",
            title: "DATA SCIENCE ALLIANCE",
            subtitle: "Analytics Platform",
            description: "Platform for international students with degrees in business analytics, machine learning, and artificial intelligence to develop skills and gain real-world experience in American work culture.",
            benefits: [
                "40+ data scientists and analysts in network",
                "Hands-on projects with real organizational data",
                "Professional development in American work culture",
                "Networking opportunities with industry professionals",
                "Portfolio development through practical projects"
            ],
            impact: [
                "Breaking barriers to employment for international students",
                "Contributing valuable insights through data analysis projects",
                "Building strong professional foundations for career growth",
                "Creating pathways to permanent employment opportunities"
            ],
            icon: "chart.bar.fill",
            contactEmail: "datascience@chieac.org"
        ),
        ProgramInfo(
            id: "program.impact",
            title: "IMPACT",
            subtitle: "Family Advocacy",
            description: "First-responder advocates addressing immediate and ongoing needs of students and families in challenging situations. Providing personalized support and guidance during critical moments.",
            benefits: [
                "150+ families supported since inception",
                "250+ emergency interventions managed",
                "$20,000+ in essential resources distributed",
                "50+ IEPs successfully advocated",
                "95% of families connected to long-term services"
            ],
            impact: [
                "Housing assistance and school enrollment support provided",
                "Mental health support and advocacy services delivered",
                "Technology and transportation assistance distributed",
                "Critical educational advocacy ensuring equitable opportunities"
            ],
            icon: "heart.fill",
            contactEmail: "impact@chieac.org"
        )
    ]
    
    static let teamMembersFallback: [TeamMember] = [
        TeamMember(id: "member.core_team.benjamin_drury", name: "Benjamin (Dr. D) Drury", title: "Founder & Executive Director", bio: "Founded ChiEAC in 2020 with passion for addressing systemic educational inequities. Left teaching at a Hispanic-Serving Institution to create practical pathways for student success.", bioShort: "Founder and Executive Director", team: .coreTeam, imageURL: nil),
        TeamMember(id: "member.core_team.renuka_sahu", name: "Renuka Sahu", title: "Business Analytics & Strategy Manager", bio: "MBA from Babson College with expertise in technology, analytics, and entrepreneurship. Focuses on turning challenges into opportunities for growth.", bioShort: "Business Analytics & Strategy Manager", team: .coreTeam, imageURL: nil),
        TeamMember(id: "member.core_team.sabian_murry", name: "Sabian Murry", title: "Education Justice Fellow", bio: "University of Chicago student studying Human Rights with pre-law focus. Mentors high school students through college application process.", bioShort: "Education Justice Fellow", team: .coreTeam, imageURL: nil),
        TeamMember(id: "member.core_team.arely_anaya", name: "Arely Anaya", title: "Chief Operations Officer", bio: "Bilingual advocate with expertise in program management, strategic outreach, and community engagement. LEAFS Fellow and 2024 Emerging Leader Award recipient.", bioShort: "Chief Operations Officer", team: .coreTeam, imageURL: nil),
        TeamMember(id: "member.core_team.danay_chapel", name: "Danay Chapel", title: "Chief Strategy Officer", bio: "30+ years in healthcare, education, and leadership. Provides critical strategic insight guiding the organization into the future while preserving mission and vision.", bioShort: "Chief Strategy Officer", team: .coreTeam, imageURL: nil),
        TeamMember(id: "member.advisory_board.yvonne_wandia", name: "Yvonne Wandia", title: "Advisory Board Member", bio: "Passionate advocate and researcher in Health Informatics with expertise in statistics and data-driven healthcare solutions.", bioShort: nil, team: .advisoryBoard, imageURL: nil),
        TeamMember(id: "member.advisory_board.tatiana_babcock", name: "Tatiana Babcock", title: "Advisory Board Member", bio: "Political Science student at DePaul University, intern with Illinois Lieutenant Governor working on Justice, Equity, and Opportunity initiatives.", bioShort: nil, team: .advisoryBoard, imageURL: nil),
        TeamMember(id: "member.advisory_board.domingo_xavier_casanova", name: "Domingo Xavier Casanova", title: "Advisory Board Member", bio: "Chief of Staff at Complement Consulting Group, successful grant writer bringing $25 million in funding to Chicagoland students and communities.", bioShort: nil, team: .advisoryBoard, imageURL: nil)
    ]
}
