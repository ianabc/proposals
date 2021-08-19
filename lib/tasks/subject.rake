namespace :birs do
  task default: 'birs:birs_subjects'

  desc "Add BIRS Subjects to database"
  task birs_subjects: :environment do
    subject_codes = [
      { code: 'ACS', title: 'Applied Computer Science' },
      { code: 'TCS', title: 'Theoretical Computer Science' },
      { code: 'COMB', title: 'Combinatorics' },
      { code: 'DM', title: 'Discrete Mathematics' },
      { code: 'DATA', title: 'Data Science' },
      { code: 'OR', title: 'Operation Research' },
      { code: 'ML', title: 'Machine Learning' },
      { code: 'CO', title: 'Control/Optimization' },
      { code: 'ASTA', title: 'Applied Statistics' },
      { code: 'STAMET', title: 'Statistical Methodology' },
      { code: 'PSTO', title: 'Probability and Stochastic Modelling' },
      { code: 'MEFS', title: 'Mathematical Economics/Finance/Social and behavioral sciences' },
      { code: 'MP', title: 'Mathematical Physics' },
      { code: 'AMP', title: 'Applied Mathematical Physics' },
      { code: 'ST', title: 'String Theory' },
      { code: 'AGEO', title: 'Algebraic Geometry' },
      { code: 'ALG', title: 'Algebraic Structures' },
      { code: 'REP', title: 'Representation Theory' },
      { code: 'ATOP', title: 'Algebraic Topology' },
      { code: 'TOP', title: 'Topology' },
      { code: 'ARGEO', title: 'Arithmetic Geometry' },
      { code: 'DS', title: 'Dynamical Systems' },
      { code: 'DGEO', title: 'Differential and Complex Geometry' },
      { code: 'GGT', title: 'Geometric Group Theory' },
      { code: 'GA', title: 'Geometric Analysis' },
      { code: 'PDE', title: 'Partial Differential Equations' },
      { code: 'PPDE', title: 'Physical PDEs' },
      { code: 'GPDE', title: 'Geometric PDEs' },
      { code: 'FA', title: 'Functional/Complex Analysis' },
      { code: 'FD', title: 'Fluid Dynamics' },
      { code: 'IP', title: 'Inverse Problems' },
      { code: 'AM', title: 'Applied Mathematics' },
      { code: 'MPE', title: 'Mathematics of Planet Earth' },
      { code: 'MPE/CC', title: 'Climate Change' },
      { code: 'NA', title: 'Numerical Analysis' },
      { code: 'BIO', title: 'Mathematical Biology' },
      { code: 'ME', title: 'Math Ecology' },
      { code: 'SBIO', title: 'Systems Biology' },
      { code: 'CBIO', title: 'Computational Biology' },
      { code: 'MS', title: 'Material Science' },
      { code: 'EDU', title: 'Education / Outreach / Other' },
      { code: 'WEC', title: 'Women and Early Careers in Math' },
      { code: 'MEP', title: 'Mathematical Epidemiology' },
      { code: 'OA', title: 'Operator Algebras' },
      { code: 'MAA', title: 'Modern Applied Analysis' },
      { code: 'CC', title: 'Computational Chemistry' },
      { code: 'TSTA', title: 'Theoretical Statistics' },
      { code: 'DAM', title: 'Data Mining' },
      { code: 'STAM', title: 'Statistical Mechanics' },
      { code: 'AIM', title: 'Applied Analysis and Industrial Math' },
      { code: 'SS', title: 'Summer Schools' },
      { code: 'ANNT', title: 'Analytic Number Theory' },
      { code: 'ALNT', title: 'Algebraic Number Theory' }
    ]

    # TODO: find or create SubjectCategory and assign accordingly
    category = SubjectCategory.find_or_create_by!(name: 'none')
    subject_codes.each do |subject|
      puts "Adding BIRS Subject: #{subject[:code]}: #{subject[:title]}"
      Subject.create(code: subject[:code], title: subject[:title], subject_category: category)
    end
    puts "Done!"
  end

  desc "Add AMS Subjects to database"
  task ams_subjects: :environment do
    ams_subject_codes = [
      { code: "00-XX", title: "00 General" },
      { code: "01-XX", title: "01 History and biography" },
      { code: "03-XX", title: "03 Mathematical logic and foundations" },
      { code: "05-XX", title: "05 Combinatorics" },
      { code: "06-XX", title: "06 Order, lattices, ordered algebraic structures" },
      { code: "08-XX", title: "08 General algebraic systems" },
      { code: "11-XX", title: "11 Number theory" },
      { code: "12-XX", title: "12 Field theory and polynomials" },
      { code: "13-XX", title: "13 Commutative rings and algebras" },
      { code: "14-XX", title: "14 Algebraic geometry" },
      { code: "15-XX", title: "15 Linear and multilinear algebra; matrix theory" },
      { code: "16-XX", title: "16 Associative rings and algebras" },
      { code: "17-XX", title: "17 Nonassociative rings and algebras" },
      { code: "18-XX", title: "18 Category theory; homological algebra" },
      { code: "19-XX", title: "19 $K$-theory" },
      { code: "20-XX", title: "20 Group theory and generalizations" },
      { code: "22-XX", title: "22 Topological groups, Lie groups" },
      { code: "26-XX", title: "26 Real functions" },
      { code: "28-XX", title: "28 Measure and integration" },
      { code: "30-XX", title: "30 Functions of a complex variable" },
      { code: "31-XX", title: "31 Potential theory" },
      { code: "32-XX", title: "32 Several complex variables and analytic spaces" },
      { code: "33-XX", title: "33 Special functions " },
      { code: "34-XX", title: "34 Ordinary differential equations" },
      { code: "35-XX", title: "35 Partial differential equations" },
      { code: "37-XX", title: "37 Dynamical systems and ergodic theory" },
      { code: "39-XX", title: "39 Difference and functional equations" },
      { code: "40-XX", title: "40 Sequences, series, summability" },
      { code: "41-XX", title: "41 Approximations and expansions" },
      { code: "42-XX", title: "42 Fourier analysis" },
      { code: "43-XX", title: "43 Abstract harmonic analysis" },
      { code: "44-XX", title: "44 Integral transforms, operational calculus" },
      { code: "45-XX", title: "45 Integral equations" },
      { code: "46-XX", title: "46 Functional analysis" },
      { code: "47-XX", title: "47 Operator theory" },
      { code: "49-XX", title: "49 Calculus of variations and optimal control; optimization" },
      { code: "51-XX", title: "51 Geometry" },
      { code: "52-XX", title: "52 Convex and discrete geometry" },
      { code: "53-XX", title: "53 Differential geometry" },
      { code: "54-XX", title: "54 General topology" },
      { code: "55-XX", title: "55 Algebraic topology" },
      { code: "57-XX", title: "57 Manifolds and cell complexes" },
      { code: "58-XX", title: "58 Global analysis, analysis on manifolds" },
      { code: "60-XX", title: "60 Probability theory and stochastic processes" },
      { code: "62-XX", title: "62 Statistics" },
      { code: "65-XX", title: "65 Numerical analysis" },
      { code: "68-XX", title: "68 Computer science" },
      { code: "70-XX", title: "70 Mechanics of particles and systems" },
      { code: "74-XX", title: "74 Mechanics of deformable solids" },
      { code: "76-XX", title: "76 Fluid mechanics" },
      { code: "78-XX", title: "78 Optics, electromagnetic theory" },
      { code: "80-XX", title: "80 Classical thermodynamics, heat transfer" },
      { code: "81-XX", title: "81 Quantum theory" },
      { code: "82-XX", title: "82 Statistical mechanics, structure of matter" },
      { code: "83-XX", title: "83 Relativity and gravitational theory" },
      { code: "85-XX", title: "85 Astronomy and astrophysics" },
      { code: "86-XX", title: "86 Geophysics" },
      { code: "90-XX", title: "90 Operations research, mathematical programming" },
      { code: "91-XX", title: "91 Game theory, economics, social and behavioral sciences" },
      { code: "92-XX", title: "92 Biology and other natural sciences" },
      { code: "93-XX", title: "93 Systems theory; control" },
      { code: "94-XX", title: "94 Information and communication, circuits" },
      { code: "97-XX", title: "97 Mathematics education" },
      { code: "99-XX", title: "99 Other" }
    ]

    ams_subject_codes.each do |ams_subject|
      puts "Adding AMS Subject: #{ams_subject[:title]}"
      AmsSubject.create(code: ams_subject[:code], title: ams_subject[:title])
    end
    puts "Done!"
  end

  desc "Add New Subjects to database"
  task new_subjects: :environment do
    new_subjects = [
      { code: "MML", title: "Mathematical Logic" },
      { code: "CE", title: "Commercialization and Entrepreneurship" }
    ]

    category = SubjectCategory.find_or_create_by!(name: 'none')
    new_subjects.each do |subject|
      puts "Adding new subject: #{subject[:code]} => #{subject[:title]}"
      Subject.create(code: subject[:code], title: subject[:title], subject_category: category)
    end
  end

  desc "Update Ams Subjects database"
  task update_ams_subjects: :environment do
    Proposal.all.each do |proposal|
      next if proposal.ams_subjects.first.nil?

      proposal.ams_subjects.each do |subject|
        case subject.code
        when 'code1'
          first_code = subject.title.split.first
          first_code += "-XX"
          subject.update(code: first_code)
          ProposalAmsSubject.create!(ams_subject: subject, proposal: proposal, code: 'code1')
        when 'code2'
          first_code = subject.title.split.first
          first_code += "-XX"
          subject.update(code: first_code)
          ProposalAmsSubject.create!(ams_subject: subject, proposal: proposal, code: 'code2')
        end
      end
    end
  end
end
