namespace :birs do
  desc "Add default survey form text to database"
  task add_survey: :environment do
    survey = { introduction: 'BIRS is committed to providing a welcoming environment to all participants at BIRS events.
            It is our goal to host workshops that are demographically diverse, and to foster opportunities for career
            growth and development that are inclusive to all.
            The collection of information from our participants is one way that BIRS supports this goal.
            This information enables us to see trends, improvements, and shortfalls in the diversity of
            our participants. Ultimately it provides data that canbe used for evidence-based decision-making
             to promote greater inclusion and diversity within mathematics.
            Your answers to this survey will be stored electronically upon submission and access is
            limited to BIRS staff on a need-to-know basis.
            It will not be shared further in an identifiable form.
            Answers to some common questions about the survey can befound here.',
               disclaimer: 'All applicants must complete and submit a self-identification questionnaire when
            applying to BIRS. However, you may choose “prefer not to answer’ for any or all of the questions
            if you prefer not to self-identify. Although self-identifying is encouraged, there are no consequences
            or penalties if you choose not to. Your self-identification information is not partof your application,
            and is neither accessible to, shared with, external reviewers and/or selection committee members in an
            identifiable form.' }

    survey = Survey.find_or_create_by!(introduction: survey[:introduction], disclaimer: survey[:disclaimer])

    survey_questions = [
      { statement: "1. What is your country of citizenship?", options: { Argentina: 'Argentina',
                                                                         Australia: ' Australia', Austria: 'Austria', Belarus: 'Belarus', Belgium: 'Belgium',
                                                                         Benin: 'Benin', Brazil: 'Brazil', Canada: 'Canada', Chile: 'Chile', China: 'China',
                                                                         Colombia: 'Colombia', 'Costa Rica': 'Costa Rica', Croatia: 'Croatia', Cyprus: 'Cyprus',
                                                                         'Czech Republic': 'Czech Republic', Denmark: 'Denmark', Egypt: 'Egypt',
                                                                         Finland: 'Finland', France: 'France', Germany: 'Germany', Greece: 'Greece',
                                                                         Guanajuato: 'Guanajuato', 'Hong Kong': 'Hong Kong', Hungary: 'Hungary',
                                                                         Iceland: 'Iceland', India: 'India', Indonesia: 'Indonesia', Iran: 'Iran',
                                                                         Iraq: 'Iraq', Israel: 'Israel', Italy: 'Italy', Japan: 'Japan',
                                                                         London: 'London', Luxembourg: 'Luxembourg', Macau: 'Macau',
                                                                         Malaysia: 'Malaysia', Mexico: 'Mexico', Morocco: 'Morocco',
                                                                         Netherlands: 'Netherlands', 'New Zealand': 'New Zealand', Norway: 'Norway',
                                                                         Perú: 'Perú', Philippines: 'Philippines', Poland: 'Poland',
                                                                         Portugal: 'Portugal', Romania: 'Romania', Russia: 'Russia',
                                                                         'Saudi Arabia': 'Saudi Arabia', 'Sierra Leone': 'Sierra Leo', Singapore: 'Singapore',
                                                                         Slovakia: 'Slovakia', Slovenia: 'Slovenia', 'South Korea': 'South Korea',
                                                                         Spain: 'Spain', Sweden: 'Sweden', Switzerland: 'Switzerland', Taiwan: 'Taiwan',
                                                                         'The Bahamas': 'The Bahamas', Turkey: 'Turkey', UAE: 'UAE', Ukraine: 'Ukraine',
                                                                         'United Kingdom': 'United Kingdom', Uruguay: 'Uruguay', USA: 'USA',
                                                                         Venezuela: 'Venezuela', Vienna: 'Vienna', Vietnam: 'Vietnam',
                                                                         Other: 'Other', 'Prefer not to answer': '' }, select: "multiple" },
      { statement: "2. Do you identify as an indigenous person?",
        options: { Yes: 'Yes', No: 'No', 'Prefer not to answer': '' }, select: "multiple" },
      { statement: "3. How do you describe your ethnicity?", options: { 'African/Black (including African-American,
            African-Canadian, AfroCaribbean, etc.)': 'African/Black (including African-American, African-Canadian,
            AfroCaribbean, etc.)', Arab: 'Arab', 'East Asian': 'East Asian', 'European/non-white': 'European/non-white',
                                                                        'European/white': 'European/white', 'Filipina/Filipino': 'Filipina/Filipino',
                                                                        'Indigenous from within North America': 'Indigenous from within North America',
                                                                        'Indigenous from outside North America': 'Indigenous from outside North America',
                                                                        'Latin, South, or Central American': 'Latin, South, or Central American',
                                                                        'South Asian (including Indian sub-continent, Indo-Caribbean, Indo-African, Indo-Fijian, West-Indian)':
                'South Asian (including Indian sub-continent, Indo-Caribbean, Indo-African, Indo-Fijian, West-Indian)',
                                                                        'Southeast Asian': 'Southeast Asian', 'West Asian': 'West Asian', 'Prefer Other': 'Prefer Other',
                                                                        'Prefer not to answer': '' }, select: "single" },
      { statement: "4. How do you describe your gender?", options: { Female: 'Female', Male: 'Male', 'Gender Fluid
            and/or non-Binary Person': 'Gender Fluid and/or non-Binary Person', Other: 'Other',
                                                                     'Prefer not to answer': '' }, select: "single" },
      { statement: "5. Do you identify as a member of the 2SLGBTQIA+ community?",
        options: { Yes: 'Yes', No: 'No', 'Prefer not to answer': '' }, select: "single" },
      { statement: "6. Do you have a disability,impairment, or ongoing medical condition that impacts
        your participation in everyday life?", options: { Yes: 'Yes', No: 'No', 'Prefer not to answer': '' }, select: "single" },
      { statement: "7. Do you consider yourself to be part of anunder-represented minority in the country
        of your current affiliation?", options: { Yes: 'Yes', No: 'No', 'Prefer not to answer': '' }, select: "single" },
      { statement: "8. Do you consider yourself to be part of anunder-represented minority in STEM?",
        options: { Yes: 'Yes', No: 'No', 'Prefer not to answer': '' }, select: "single" },
      { statement: "9. Do you consider yourself to be part of an under-represented minority in your research area?",
        options: { Yes: 'Yes', No: 'No', 'Prefer not to answer': '' }, select: "single" }
    ]
    survey_questions.each do |survey_question|
      SurveyQuestion.create(statement: survey_question[:statement], options: survey_question[:options], select: survey_question[:select], survey: survey)
    end
  end
end
