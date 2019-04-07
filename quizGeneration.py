#!/usr/bin/env python3
'''
	QuizGenerator.py - Creates quizzes with questions and answers in
  random order, along with the answer key
'''
import random
import json

with open('america_state.json', 'r') as f:
	capitals = json.loads(f.read())

#print(capitals)
#print(type(capitals))

# generate 2 paper
for quizNum in range(2):
	# Create the quiz and answer key files.
	quizFile = open('capitalsquiz%s.txt' % (quizNum + 1), 'w')
	answerKeyFile = open('capitalsquiz_answers%s.txt' % (quizNum + 1), 'w')

	# Write out the header for the quiz.
	quizFile.write('Name:\n\nDate:\n\nPeriod:\n\n')
	quizFile.write((' ' * 20) + 'State Capitals Quiz (Form %s)' % (quizNum + 1))
	quizFile.write('\n\n')

	# Shuffle the order of the states.
	states = list(capitals.keys())
	random.shuffle(states)

# Loop through all 10 states, making a question for each.
	for questionNum in range(10):

			# Get right and wrong answers.
		correctAnswer = capitals[states[questionNum]]
		wrongAnswers = list(capitals.values())
		del wrongAnswers[wrongAnswers.index(correctAnswer)]
		wrongAnswers = random.sample(wrongAnswers, 3)
		answerOptions = wrongAnswers + [correctAnswer]
		random.shuffle(answerOptions)
		#print(answerOptions)
		#print(correctAnswer)
		#print(wrongAnswers)
		quizFile.write('%s what is the capital of %s\n\n' % (questionNum+1, states[questionNum]))
		for i in range(4):
			quizFile.write(' %s. %s\n' % ('ABCD'[i], answerOptions[i]))
			quizFile.write('\n')
		answerKeyFile.write('%s. %s\n' % (questionNum + 1, 'ABCD'[answerOptions.index(correctAnswer)]))
	quizFile.close()
	answerKeyFile.close()
