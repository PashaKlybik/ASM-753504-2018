// LR7.cpp : Определяет точку входа для приложения.
//Лабораторная работа 7
//
//Разработка оконного приложения под платформу Win32
//
//Создать оконное приложение, в котором на главном окне будет кнопка Clear.
//При щелчке мышью в любую точку нашего окна необходимо нарисовать 
//небольшое изображение с центром в этой точке(например, елочку или домик).
//Нажатие на кнопку Clear должно очищать наше окно.
//Работу надо выполнять без библиотек типа Windows Forms, а напрямую используя функции работы с окнами.

#include "stdafx.h"
#include "LR7.h"
#include <Windows.h>
#include <windowsx.h>
#include <vector>
using namespace std;

#define MAX_LOADSTRING 100
#define IDM_HOUSERBUTTON 1001
#define IDM_CLEARBUTTON 1004

// Глобальные переменные:
HINSTANCE hInst;                                // текущий экземпляр
WCHAR szTitle[MAX_LOADSTRING];                  // Текст строки заголовка
WCHAR szWindowClass[MAX_LOADSTRING];            // имя класса главного окна

vector<pair<int, pair<int, int>>> points;
int drawFlag = 0;

// Отправить объявления функций, включенных в этот модуль кода:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPWSTR    lpCmdLine,
	_In_ int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

	// TODO: Разместите код здесь.



	// Инициализация глобальных строк
	LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadStringW(hInstance, IDC_LR7, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Выполнить инициализацию приложения:
	if (!InitInstance(hInstance, nCmdShow))
	{
		return FALSE;
	}

	HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LR7));

	MSG msg;

	// Цикл основного сообщения:
	while (GetMessage(&msg, nullptr, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return (int)msg.wParam;
}

//
//  ФУНКЦИЯ: MyRegisterClass()
//
//  ЦЕЛЬ: Регистрирует класс окна.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEXW wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = WndProc;													// как будет обрабатываться сообщ
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LR7));
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = MAKEINTRESOURCEW(IDC_LR7);
	wcex.lpszClassName = szWindowClass;											// имя нашего класса
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassExW(&wcex);
}

//
//   ФУНКЦИЯ: InitInstance(HINSTANCE, int)
//
//   ЦЕЛЬ: Сохраняет маркер экземпляра и создает главное окно
//
//   КОММЕНТАРИИ:
//
//        В этой функции маркер экземпляра сохраняется в глобальной переменной, а также
//        создается и выводится главное окно программы.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
	hInst = hInstance; // Сохранить маркер экземпляра в глобальной переменной

	HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);
	HWND hHouseButton = CreateWindow(_T("BUTTON"), _T("LOVE"), WS_CHILD | WS_VISIBLE, 1390, 510, 130, 50, hWnd, (HMENU)IDM_HOUSERBUTTON, hInst, 0);
	HWND hClearButton = CreateWindow(_T("BUTTON"), _T("CLEAR"), WS_CHILD | WS_VISIBLE, 1390, 720, 130, 50, hWnd, (HMENU)IDM_CLEARBUTTON, hInst, 0);

	if (!hWnd)
	{
		return FALSE;
	}

	ShowWindow(hWnd, SW_SHOWMAXIMIZED);
	UpdateWindow(hWnd);

	return TRUE;
}

//
//  ФУНКЦИЯ: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  ЦЕЛЬ: Обрабатывает сообщения в главном окне.
//
//  WM_COMMAND  - обработать меню приложения
//  WM_PAINT    - Отрисовка главного окна
//  WM_DESTROY  - отправить сообщение о выходе и вернуться
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_COMMAND:
	{
		int wmId = LOWORD(wParam);
		switch (wmId)
		{
		case IDM_HOUSERBUTTON:
			drawFlag = 1;
			break;
		case IDM_CLEARBUTTON:
			points.clear();
			InvalidateRect(hWnd, NULL, TRUE);
			break;
		case IDM_ABOUT:
			DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
			break;
		case IDM_EXIT:
			DestroyWindow(hWnd);
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
		}
	}
	break;
	case WM_PAINT:
	{
		PAINTSTRUCT ps;
		HDC hdc = BeginPaint(hWnd, &ps);

		HPEN hBlackPen, hRedPen;
		hRedPen = CreatePen(PS_SOLID, 1, RGB(254, 32, 31));
		hBlackPen = CreatePen(PS_SOLID, 1, RGB(0, 0, 0));
		HBRUSH hBlackBrush, hRedBrush;
		hRedBrush = CreateSolidBrush(RGB(254, 32, 31));
		hBlackBrush = CreateSolidBrush(RGB(0, 0, 0));

		for (int i = 0; i < points.size(); i++)
		{
			int x = points[i].second.first;
			int y = points[i].second.second;

			SelectObject(hdc, hBlackPen);
			SelectObject(hdc, hBlackBrush);

			POINT SI[8] = { { x + 30, y + 25 }, { x, y + 25 }, { x, y - 25 }, { x + 30, y - 25 },
			{ x + 30, y - 15 }, { x + 10, y - 15 }, { x + 10, y + 15 }, { x + 30, y + 15 } };
			Polygon(hdc, SI, 8);

			Rectangle(hdc, x + 55, y + 20, x + 65, y - 20);
			Rectangle(hdc, x + 40, y + 5, x + 80, y - 5);

			Rectangle(hdc, x + 105, y + 20, x + 115, y - 20);
			Rectangle(hdc, x + 90, y + 5, x + 130, y - 5);

			Rectangle(hdc, x - 105, y + 25, x - 95, y - 25);

			SelectObject(hdc, hRedPen);
			SelectObject(hdc, hRedBrush);
			POINT HEART[11] = { { x - 20, y - 5 }, { x - 20, y - 15 }, { x - 30, y - 25 }, { x - 40, y - 25 }, 
			{ x - 50, y - 15 }, { x - 60, y - 25 }, { x - 70, y - 25 }, { x - 80, y - 15 },
			{ x - 80, y - 5 }, { x - 50, y + 25 }, { x - 20, y - 5 } };
			Polygon(hdc, HEART, 11);
		}

		DeleteObject(hBlackPen);
		DeleteObject(hRedPen);
		DeleteObject(hBlackBrush);
		DeleteObject(hRedBrush);

		EndPaint(hWnd, &ps);
	}
	break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	case WM_LBUTTONDOWN:
	{
		if (drawFlag != 0)
		{
			int xPos = GET_X_LPARAM(lParam);
			int yPos = GET_Y_LPARAM(lParam);
			points.push_back(pair<int, pair<int, int>>(drawFlag, pair<int, int>(xPos, yPos)));
			InvalidateRect(hWnd, 0, TRUE);
		}
	}
	break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

// Обработчик сообщений для окна "О программе".
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	UNREFERENCED_PARAMETER(lParam);
	switch (message)
	{
	case WM_INITDIALOG:
		return (INT_PTR)TRUE;

	case WM_COMMAND:
		if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
		{
			EndDialog(hDlg, LOWORD(wParam));
			return (INT_PTR)TRUE;
		}
		break;
	}
	return (INT_PTR)FALSE;
}